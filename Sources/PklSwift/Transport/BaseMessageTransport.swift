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

import Foundation
import PklMessagePack

/// A ``MessageTransport`` base class that implements core message handling logic
public class BaseMessageTransport: MessageTransport, @unchecked Sendable {
    var reader: Reader!
    var writer: Writer!
    var encoder: MessagePackEncoder!
    var decoder: MessagePackDecoder!

    var running: Bool { true }

    func send(_ message: ClientMessage) throws {
        debug("Sending message: \(message)")

        try message.encode(to: self.encoder)
    }

    func close() throws {}

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
                        let message = try decodeMessage(from: self.decoder)
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
        // Read directly into the caller's buffer via POSIX read() to avoid
        // the per-call NSConcreteData allocation from NSFileHandle.read(upToCount:).
        // Loop until all requested bytes are read or EOF — short reads are
        // normal on pipes (e.g., the JVM writes through an 8 KB BufferedOutputStream).
        guard let base = into.baseAddress else { return 0 }
        let fd = fileDescriptor
        var totalRead = 0
        while totalRead < into.count {
            let n = Foundation.read(fd, base + totalRead, into.count - totalRead)
            if n < 0 {
                throw POSIXError(.init(rawValue: errno) ?? .EIO)
            }
            if n == 0 { break }
            totalRead += n
        }
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
