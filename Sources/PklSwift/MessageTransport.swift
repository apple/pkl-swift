// ===----------------------------------------------------------------------===//
// Copyright © 2024 Apple Inc. and the Pkl project authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//	https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ===----------------------------------------------------------------------===//

import Foundation
import MessagePack
import SemanticVersion

protocol MessageTransport {
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
        guard let data = try read(upToCount: into.count) else { return 0 }
        data.copyBytes(to: into)
        return data.count
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
public class BaseMessageTransport: MessageTransport {
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
            Task {
                while self.running {
                    do {
                        let arrayLength = try decoder.decodeArrayLength()
                        assert(arrayLength == 2)
                        let code = try decoder.decode(as: MessageType.self)
                        let message = try decodeMessage(code)
                        debug("Received message: \(message)")
                        continuation.yield(message)
                    } catch {
                        if self.running {
                            continuation.finish(throwing: error)
                        }
                    }
                }
                continuation.finish()
            }
        }
    }
}

/// A ``MessageTransport`` that sends and receives messages by spawning Pkl as a child process.
public class ServerMessageTransport: BaseMessageTransport {
    var process: Process?
    let pklCommand: [String]?

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
        debug("Spawning command \(pklCommand[0]) with arguments \(arguments)")
        try self.process!.run()
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
        if self.process == nil {
            return
        }
        #if os(Linux)
        // workaround: https://github.com/apple/swift-corelibs-foundation/issues/4772
        if let process = self.process, process.isRunning {
            kill(process.processIdentifier, SIGKILL)
        }
        #else
        self.process?.terminate()
        #endif
        self.process!.waitUntilExit()
        self.process = nil
    }

    override func getMessages() throws -> AsyncThrowingStream<ServerMessage, Error> {
        try self.ensureProcessStarted()
        return try super.getMessages()
    }
}

public class ExternalReaderMessageTransport: BaseMessageTransport {
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
