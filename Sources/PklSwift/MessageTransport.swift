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
// Import it explicitly for `read`, `errno`, and `fcntl`.
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

#if canImport(Subprocess)
import Subprocess

// Match the module swift-subprocess uses for `FilePath`/`FileDescriptor`
#if canImport(System)
import System
#else
import SystemPackage
#endif
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
    func close() async
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

    func close() async {}

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
#if canImport(Subprocess)
#if canImport(System)
/// Sets the close-on-exec flag on a file descriptor.
/// Used on Darwin, where the atomic `FileDescriptor.pipe(options: .closeOnExec)` isn't available; see the call site.
private func setCloseOnExec(_ fd: FileDescriptor) {
    _ = fcntl(fd.rawValue, F_SETFD, FD_CLOEXEC)
}
#endif

public class ServerMessageTransport: BaseMessageTransport, @unchecked Sendable {
    let pklCommand: [String]?

    /// The task running the `pkl server` child for its entire lifetime.
    /// `run(_:)` returns when the child exits; cancellation fires the teardown sequence (graceful shutdown, then SIGKILL).
    private var runTask: Task<Void, Error>?

    private let _running = PklLockedValueBox(false)
    override var running: Bool { self._running.withLockedValue { $0 } }

    override convenience init() {
        self.init(pklCommand: nil)
    }

    init(pklCommand: [String]?) {
        self.pklCommand = pklCommand
    }

    private func ensureProcessStarted() throws {
        if self.running { return }
        let pklCommand = try getPklCommand()

        // Own both pipes.
        // The child ends go to Subprocess (`closeAfterSpawningProcess: true`), which closes them on both success and failure so we never close them ourselves.
        //
        // Create the pipes close-on-exec so they can't leak into an unrelated child spawned elsewhere in this process.
        // `pipe(options:)` does this atomically but is macOS 27+ only, so on Darwin fall back to fcntl after creation.
        #if canImport(System)
        let stdinPipe = try FileDescriptor.pipe()
        let stdoutPipe = try FileDescriptor.pipe()
        for fd in [stdinPipe.readEnd, stdinPipe.writeEnd, stdoutPipe.readEnd, stdoutPipe.writeEnd] {
            setCloseOnExec(fd)
        }
        #else
        let stdinPipe = try FileDescriptor.pipe(options: .closeOnExec)
        let stdoutPipe = try FileDescriptor.pipe(options: .closeOnExec)
        #endif
        self.reader = FileHandle(fileDescriptor: stdoutPipe.readEnd.rawValue, closeOnDealloc: true)
        self.writer = FileHandle(fileDescriptor: stdinPipe.writeEnd.rawValue, closeOnDealloc: true)
        self.encoder = .init(writer: self.writer)
        self.decoder = .init(reader: self.reader)

        let arguments = Array(pklCommand.dropFirst()) + ["server"]
        debug("Spawning command \(pklCommand[0]) with arguments \(arguments)")

        var platformOptions = PlatformOptions()
        // `close()` cancels the task, which runs this teardown (always ending in SIGKILL), so a child that won't exit can't hang teardown.
        platformOptions.teardownSequence = [
            .gracefulShutDown(allowedDurationToNextStep: .seconds(5)),
        ]

        let executablePath = FilePath(pklCommand[0])
        let launchArguments = Arguments(arguments)
        let childStdin = stdinPipe.readEnd
        let childStdout = stdoutPipe.writeEnd
        self._running.withLockedValue { $0 = true }
        self.runTask = Task { [weak self] in
            defer { self?._running.withLockedValue { $0 = false } }
            do {
                _ = try await run(
                    .path(executablePath),
                    arguments: launchArguments,
                    platformOptions: platformOptions,
                    input: .fileDescriptor(childStdin, closeAfterSpawningProcess: true),
                    output: .fileDescriptor(childStdout, closeAfterSpawningProcess: true),
                    error: .fileDescriptor(.standardError, closeAfterSpawningProcess: false)
                )
            } catch {
                debug("pkl server process ended with error: \(error)")
            }
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

    override func close() async {
        guard let runTask = self.runTask else {
            return
        }
        self._running.withLockedValue { $0 = false }
        // Tear down the child process
        // Await the task completion (bounded by teardown durations)
        // The child closes its stdout write end, unblocking task completion
        runTask.cancel()
        _ = try? await runTask.value
        self.runTask = nil
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

    override func close() async {
        self._running = false
    }
}
