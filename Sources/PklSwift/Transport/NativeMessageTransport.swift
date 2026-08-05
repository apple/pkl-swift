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

#if libpkl
import Foundation
import PklMessagePack

public class NativeMessageTransport: MessageTransport, @unchecked Sendable {
    var client: LibPklClient?

    private func getClient() throws -> LibPklClient {
        if let client {
            if client.closed {
                throw PklError("LibPklClient is closed")
            }
            return client
        } else {
            let c = try LibPklClient()
            client = c
            return c
        }
    }

    func send(_ message: any ClientMessage) throws {
        let client = try getClient()
        let writer: BufferWriter = .init()
        let encoder: MessagePackEncoder = .init(writer: writer)
        try message.encode(to: encoder)
        let bytes = writer.bytes
        try client.sendMessage(bytes: bytes)
    }

    func getMessages() throws -> AsyncThrowingStream<any ServerMessage, any Error> {
        let client = try getClient()
        let bytesStream = client.getMessages()
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await bytes in bytesStream {
                        let reader: BufferReader = .init(bytes)
                        let decoder: MessagePackDecoder = .init(reader: reader)
                        let message = try decodeMessage(from: decoder)
                        debug("Received message: \(message)")
                        continuation.yield(message)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func close() throws {
        if let client = self.client {
            try client.close()
        }
    }
}
#endif
