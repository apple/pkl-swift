//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the Pkl project authors. All rights reserved.
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

#if os(macOS) || os(Linux) || os(Windows)
#if !libpkl
import Foundation
import PklMessagePack

/// A ``MessageTransport`` that sends and receives messages by spawning Pkl as a child process.
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
        try self.process!.run()
    }

    override func send(_ message: ClientMessage) throws {
        try self.ensureProcessStarted()
        try super.send(message)
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
        self.processTerminationGroup.wait()
        self.process = nil
    }

    override func getMessages() throws -> AsyncThrowingStream<ServerMessage, Error> {
        try self.ensureProcessStarted()
        return try super.getMessages()
    }
}
#endif
#endif
