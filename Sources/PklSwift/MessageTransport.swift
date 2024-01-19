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
        let data = try fileHandleForReading.read(upToCount: into.count)
        if data == nil {
            return 0
        }
        data!.copyBytes(to: into)
        return data!.count
    }

    public func close() throws {
        fileHandleForReading.closeFile()
    }
}

extension Pipe: Writer {
    public func write(_ buffer: UnsafeRawBufferPointer) throws {
        try fileHandleForWriting.write(contentsOf: buffer)
    }
}

/// A ``MessageTransport`` that sends and receives messages by spawning Pkl as a child process.
public class ChildProcessMessageTransport: MessageTransport {
    var reader: Pipe!
    var writer: Pipe!
    var encoder: MessagePackEncoder!
    var decoder: MessagePackDecoder!
    var process: Process?
    let pklCommand: [String]?

    convenience init() {
        self.init(pklCommand: nil)
    }

    init(pklCommand: [String]?) {
        self.pklCommand = pklCommand
    }

    private func getPklCommand() throws -> [String] {
        if let exec = ProcessInfo.processInfo.environment["PKL_EXEC"] {
            return exec.components(separatedBy: " ")
        }
        guard let path = ProcessInfo.processInfo.environment["PATH"] else {
            throw PklError("Unable to find `pkl` command on PATH.")
        }
        for dir in path.components(separatedBy: ":") {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: dir)
                if let pkl = contents.first(where: { $0 == "pkl" }) {
                    let file = NSString.path(withComponents: [dir, pkl])
                    if FileManager.default.isExecutableFile(atPath: file) {
                        return [file]
                    }
                }
            } catch {
                if error._domain == NSCocoaErrorDomain {
                    continue
                }
                throw error
            }
        }
        throw PklError("Unable to find `pkl` command on PATH.")
    }

    private func ensureProcessStarted() throws {
        if self.process?.isRunning == true { return }
        let pklCommand = try getPklCommand()
        self.process = Process()
        self.process!.executableURL = URL(fileURLWithPath: pklCommand[0])
        var arguments = Array(pklCommand.dropFirst())
        arguments.append("server")
        self.process!.arguments = arguments
        self.reader = .init()
        self.writer = .init()
        self.encoder = .init(writer: self.writer)
        self.decoder = .init(reader: self.reader)
        self.process!.standardOutput = self.reader
        self.process!.standardInput = self.writer
        debug("Spawning command \(pklCommand[0]) with arguments \(arguments)")
        try self.process!.run()
    }

    func send(_ message: ClientMessage) throws {
        try self.ensureProcessStarted()
        debug("Sending message: \(message)")

        let messageType = MessageType.getMessageType(message)
        try self.encoder.encodeArrayHeader(2)
        try self.encoder.encode(messageType)
        try self.encoder.encode(message)
    }

    func close() {
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

    private func decodeMessage(_ messageType: MessageType) throws -> ServerMessage {
        switch messageType {
        case MessageType.CREATE_EVALUATOR_RESPONSE:
            return try self.decoder.decode(as: CreateEvaluatorResponse.self)
        case MessageType.EVALUATOR_RESPOSNE:
            return try self.decoder.decode(as: EvaluateResponse.self)
        case MessageType.READ_MODULE_REQUEST:
            return try self.decoder.decode(as: ReadModuleRequest.self)
        case MessageType.LOG_MESSAGE:
            return try self.decoder.decode(as: LogMessage.self)
        case MessageType.READ_RESOURCE_REQUEST:
            return try self.decoder.decode(as: ReadResourceRequest.self)
        case MessageType.LIST_MODULES_REQUEST:
            return try self.decoder.decode(as: ListModulesRequest.self)
        case MessageType.LIST_RESOURCES_REQUEST:
            return try self.decoder.decode(as: ListResourcesRequest.self)
        default:
            fatalError("Unreachable code")
        }
    }

    func getMessages() throws -> AsyncThrowingStream<ServerMessage, Error> {
        try self.ensureProcessStarted()
        return AsyncThrowingStream { continuation in
            Task {
                while self.process?.isRunning == true {
                    do {
                        let arrayLength = try decoder.decodeArrayLength()
                        assert(arrayLength == 2)
                        let code = try decoder.decode(as: MessageType.self)
                        let message = try decodeMessage(code)
                        debug("Received message: \(message)")
                        continuation.yield(message)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
                continuation.finish()
            }
        }
    }
}
