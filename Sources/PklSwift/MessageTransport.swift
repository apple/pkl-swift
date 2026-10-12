//===----------------------------------------------------------------------===//
// Copyright © 2024-2026 Apple Inc. and the Pkl project authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//===----------------------------------------------------------------------===//

import Foundation
import PklMessagePack
import SemanticVersion

// Foundation only re-exports the C library on some platforms, such as Darwin and Glibc.
// Import it explicitly for `read`, `errno`, `kill`, and `SIGKILL`.
// None of these are used on Windows.
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(Android)
import Android
#endif

#if !os(Windows)
/// Calls the C library's `read`.
///
/// This lives at file scope so that the name `read` isn't shadowed by ``FileHandle/read(into:)``.
private func posixRead(_ fd: Int32, _ buffer: UnsafeMutableRawPointer, _ count: Int) -> Int {
    read(fd, buffer, count)
}
#endif

protocol MessageTransport: Sendable {
    /// Send a message to the Pkl server.
    func send(_ message: ClientMessage) throws

    /// Returns a stream that yields messages from the pkl server over time.
    func getMessages() throws -> AsyncThrowingStream<ServerMessage, Error>

    /// Close the transport.
    func close()
}

extension Pipe: Reader {
    public func read(into: UnsafeMutableRawBufferPointer) throws -> Int {
        try fileHandleForReading.read(into: into)
    }

    public func close() throws {
        try fileHandleForReading.close()
    }
}

extension FileHandle: Reader {
    public func read(into: UnsafeMutableRawBufferPointer) throws -> Int {
        guard let base = into.baseAddress else { return 0 }
        var totalRead = 0
        #if os(Windows)
        // `FileHandle.fileDescriptor` is unavailable on Windows, so use the public API.
        // Loop until all requested bytes are read or EOF.
        while totalRead < into.count {
            guard let data = try self.read(upToCount: into.count - totalRead), !data.isEmpty else { break }
            data.copyBytes(to: UnsafeMutableRawBufferPointer(start: base + totalRead, count: data.count))
            totalRead += data.count
        }
        #else
        // Read directly into the caller's buffer via POSIX read() to avoid
        // the per-call NSConcreteData allocation from NSFileHandle.read(upToCount:).
        // Loop until all requested bytes are read or EOF — short reads are
        // normal on pipes (e.g., the JVM writes through an 8 KB BufferedOutputStream).
        let fd = fileDescriptor
        while totalRead < into.count {
            let n = posixRead(fd, base + totalRead, into.count - totalRead)
            if n < 0 {
                throw POSIXError(.init(rawValue: errno) ?? .EIO)
            }
            if n == 0 { break }
            totalRead += n
        }
        #endif
        return totalRead
    }

    public func close() throws {
        closeFile()
    }
}

extension Pipe: Writer {
    public func write(_ buffer: UnsafeRawBufferPointer) throws {
        try fileHandleForWriting.write(buffer)
    }
}

extension FileHandle: Writer {
    public func write(_ buffer: UnsafeRawBufferPointer) throws {
        try self.write(contentsOf: buffer)
    }
}

/// A ``MessageTransport`` base class that implements core message handling logic
public class BaseMessageTransport: MessageTransport, @unchecked Sendable {
    var reader: Reader!
    var writer: Writer!
    var encoder: MessagePackEncoder!
    var decoder: MessagePackDecoder!

    var running: Bool { true }

    func send(_ message: ClientMessage) throws {
        debug("Sending message: \(message)")

        let messageType = MessageType.getMessageType(message)
        try self.encoder.encodeArrayHeader(2)
        try self.encoder.encode(messageType)
        try self.encoder.encode(message)
    }

    fileprivate func decodeMessage(_ messageType: MessageType) throws -> ServerMessage {
        switch messageType {
        case MessageType.READ_MODULE_REQUEST:
            return try self.decoder.decode(as: ReadModuleRequest.self)
        case MessageType.READ_RESOURCE_REQUEST:
            return try self.decoder.decode(as: ReadResourceRequest.self)
        case MessageType.LIST_MODULES_REQUEST:
            return try self.decoder.decode(as: ListModulesRequest.self)
        case MessageType.LIST_RESOURCES_REQUEST:
            return try self.decoder.decode(as: ListResourcesRequest.self)
        default:
            throw PklBugError.unknownMessage("Received unexpected message: \(messageType)")
        }
    }

    func close() {}

    func getMessages() throws -> AsyncThrowingStream<ServerMessage, Error> {
        AsyncThrowingStream { continuation in
            // Run the blocking pipe-read loop on a dedicated GCD queue
            // instead of Swift's cooperative thread pool.  Each
            // EvaluatorManager keeps its read loop alive for the lifetime
            // of the pkl server process; blocking a cooperative-pool
            // thread for that long starves other tasks.
            let queue = DispatchQueue(label: "pkl-swift.message-reader")
            queue.async {
                while self.running {
                    do {
                        let arrayLength = try self.decoder.decodeArrayLength()
                        guard arrayLength == 2 else {
                            throw PklBugError.invalidMessageCode(
                                "Expected 2-element message array, got \(arrayLength)")
                        }
                        let code = try self.decoder.decode(as: MessageType.self)
                        let message = try self.decodeMessage(code)
                        debug("Received message: \(message)")
                        continuation.yield(message)
                    } catch {
                        continuation.finish(throwing: error)
                        return
                    }
                }
                continuation.finish()
            }
        }
    }
}

/// A ``MessageTransport`` that sends and receives messages by spawning Pkl as a child process.
#if os(macOS) || !canImport(Darwin)
public class ServerMessageTransport: BaseMessageTransport, @unchecked Sendable {
    var process: Process?
    let pklCommand: [String]?

    private let processTerminationGroup = DispatchGroup()

    override var running: Bool { self.process?.isRunning == true }

    override convenience init() {
        self.init(pklCommand: nil)
    }

    init(pklCommand: [String]?) {
        self.pklCommand = pklCommand
    }

    private func ensureProcessStarted() throws {
        if self.process?.isRunning == true { return }
        let pklCommand = try getPklCommand()
        self.process = Process()
        self.process!.executableURL = URL(fileURLWithPath: pklCommand[0])
        var arguments = Array(pklCommand.dropFirst())
        arguments.append("server")
        self.process!.arguments = arguments
        self.reader = Pipe()
        self.writer = Pipe()
        self.encoder = .init(writer: self.writer)
        self.decoder = .init(reader: self.reader)
        self.process!.standardOutput = self.reader
        self.process!.standardInput = self.writer
        let debugArguments = arguments
        debug("Spawning command \(pklCommand[0]) with arguments \(debugArguments)")
        self.processTerminationGroup.enter()
        self.process?.terminationHandler = { [processTerminationGroup] _ in
            processTerminationGroup.leave()
        }
        do {
            try self.process!.run()
        } catch {
            // `run()` failed to launch the process, so its `terminationHandler`
            // will never fire. Balance the `DispatchGroup` and drop the
            // unlaunched process, otherwise a later `close()` would block
            // forever on `processTerminationGroup.wait()` (and, before the
            // guard above, terminate a task that was never launched).
            self.processTerminationGroup.leave()
            self.process = nil
            throw error
        }
    }

    override func send(_ message: ClientMessage) throws {
        try self.ensureProcessStarted()
        try super.send(message)
    }

    override fileprivate func decodeMessage(_ messageType: MessageType) throws -> ServerMessage {
        switch messageType {
        case MessageType.CREATE_EVALUATOR_RESPONSE:
            return try self.decoder.decode(as: CreateEvaluatorResponse.self)
        case MessageType.EVALUATE_RESPONSE:
            return try self.decoder.decode(as: EvaluateResponse.self)
        case MessageType.LOG_MESSAGE:
            return try self.decoder.decode(as: LogMessage.self)
        default:
            return try super.decodeMessage(messageType)
        }
    }

    override func close() {
        guard let process = self.process else {
            return
        }
        #if !canImport(Darwin) && !os(Windows)
        // workaround: https://github.com/apple/swift-corelibs-foundation/issues/4772
        if process.isRunning {
            kill(process.processIdentifier, SIGKILL)
        }
        #else
        // Foundation's `Process.terminate()` raises `NSInvalidArgumentException`
        // ("task not launched") when the process was never successfully launched.
        // Guard on `isRunning` so a not-yet-launched (or already-exited) process
        // is a no-op, matching the branch above.
        if process.isRunning {
            process.terminate()
        }
        #endif
        self.processTerminationGroup.wait()
        self.process = nil
    }

    override func getMessages() throws -> AsyncThrowingStream<ServerMessage, Error> {
        try self.ensureProcessStarted()
        return try super.getMessages()
    }
}
#endif

public class ExternalReaderMessageTransport: BaseMessageTransport, @unchecked Sendable {
    override var running: Bool { self._running }
    private var _running = true

    init(reader: Reader, writer: Writer) {
        super.init()
        self.reader = reader
        self.writer = writer
        self.encoder = .init(writer: self.writer)
        self.decoder = .init(reader: self.reader)
    }

    override fileprivate func decodeMessage(_ messageType: MessageType) throws -> ServerMessage {
        switch messageType {
        case MessageType.INITIALIZE_MODULE_READER_REQUEST:
            return try self.decoder.decode(as: InitializeModuleReaderRequest.self)
        case MessageType.INITIALIZE_RESOURCE_READER_REQUEST:
            return try self.decoder.decode(as: InitializeResourceReaderRequest.self)
        case MessageType.CLOSE_EXTERNAL_PROCESS:
            return try self.decoder.decode(as: CloseExternalProcess.self)
        default:
            return try super.decodeMessage(messageType)
        }
    }

    override func close() {
        self._running = false
    }
}
