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
import XCTest

@testable import MessagePack
@testable import PklSwift

/// Tests for pipe partial-read handling in ``MessageTransport``.
///
/// `FileHandle.read(upToCount:)` on Darwin may return fewer bytes than
/// requested when data arrives in pipe chunks.  These tests verify that
/// ``FileHandle``'s ``Reader`` conformance and the ``getMessages()`` loop
/// handle this correctly.
class MessageTransportTest: XCTestCase {
    // MARK: - FileHandle short-read loop (pipe round-trip)

    /// Verify that large messages survive a pipe round-trip.
    ///
    /// Writes a message whose encoded size exceeds the typical pipe buffer
    /// (64 KB on macOS) from a background thread, reads it back on the test
    /// thread through the `FileHandle: Reader` extension, and checks the
    /// decoded bytes match.  Without the short-read loop, `read(upToCount:)`
    /// returns a partial buffer and the decoder misreads.
    func testLargeMessageRoundTripThroughPipe() throws {
        let pipe = Pipe()
        let payloadSize = 128 * 1024
        let payload = Data(repeating: 0xAB, count: payloadSize)

        // Write from a background thread so the pipe doesn't deadlock.
        let writeError = UnsafeSendableBox<Error?>(nil)
        let writeQueue = DispatchQueue(label: "test-writer")
        writeQueue.async {
            do {
                let writer: Writer = pipe
                let encoder = MessagePackEncoder(writer: writer)
                try encoder.encode(payload)
                pipe.fileHandleForWriting.closeFile()
            } catch {
                writeError.value = error
            }
        }

        let reader: Reader = pipe
        let decoder = MessagePackDecoder(reader: reader)
        let decoded: Data = try decoder.decode(as: Data.self)

        XCTAssertNil(writeError.value)
        XCTAssertEqual(decoded.count, payloadSize)
        XCTAssertEqual(decoded, payload)
    }

    /// Multiple large messages to verify the stream stays synchronised.
    func testMultipleLargeMessagesRoundTrip() throws {
        let pipe = Pipe()
        let messageCount = 20
        let payloadSize = 32 * 1024
        let payloads = (0..<messageCount).map { i in
            Data(repeating: UInt8(i & 0xFF), count: payloadSize)
        }

        let writeError = UnsafeSendableBox<Error?>(nil)
        let writeQueue = DispatchQueue(label: "test-writer")
        writeQueue.async {
            do {
                let writer: Writer = pipe
                let encoder = MessagePackEncoder(writer: writer)
                for payload in payloads {
                    try encoder.encode(payload)
                }
                pipe.fileHandleForWriting.closeFile()
            } catch {
                writeError.value = error
            }
        }

        let reader: Reader = pipe
        let decoder = MessagePackDecoder(reader: reader)

        for i in 0..<messageCount {
            let decoded: Data = try decoder.decode(as: Data.self)
            XCTAssertEqual(decoded.count, payloadSize,
                           "Message \(i): wrong size")
            XCTAssertEqual(decoded, payloads[i],
                           "Message \(i): content mismatch")
        }
        XCTAssertNil(writeError.value)
    }

    // MARK: - getMessages() error handling

    /// Verify that a malformed message (wrong array length) produces a
    /// recoverable error instead of a crash.
    ///
    /// The upstream code used `assert(arrayLength == 2)` which is a no-op
    /// in release builds and a crash in debug.  The fix uses `guard`-throw.
    func testMalformedArrayHeaderProducesError() async throws {
        let bufWriter = BufferWriter()
        let encoder = MessagePackEncoder(writer: bufWriter)

        // Write a valid 2-element message using a type BaseMessageTransport
        // can decode.
        try encoder.encodeArrayHeader(2)
        try encoder.encode(MessageType.READ_MODULE_REQUEST)
        try encoder.encode(
            ReadModuleRequest(requestId: 1, evaluatorId: 42,
                              uri: URL(string: "file:///test.pkl")!))

        // Write a malformed 3-element array header.
        try encoder.encodeArrayHeader(3)
        try encoder.encode(MessageType.READ_MODULE_REQUEST)
        try encoder.encode(
            ReadModuleRequest(requestId: 2, evaluatorId: 43,
                              uri: URL(string: "file:///test2.pkl")!))
        try encoder.encode("extra element")

        let reader = BufferReader(bufWriter.bytes)
        let transport = BaseMessageTransport()
        transport.reader = reader
        transport.decoder = MessagePackDecoder(reader: reader)

        let stream = try transport.getMessages()
        var messages: [ServerMessage] = []
        var streamError: Error? = nil

        do {
            for try await message in stream {
                messages.append(message)
            }
        } catch {
            streamError = error
        }

        // The first message should decode successfully.
        XCTAssertEqual(messages.count, 1)
        XCTAssertTrue(messages.first is ReadModuleRequest)

        // The second message (3-element array) should produce an error,
        // not a crash.
        XCTAssertNotNil(streamError,
                        "Malformed array header should produce an error")
    }
}

// MARK: - Helpers

/// A simple `@unchecked Sendable` wrapper for passing mutable state across
/// concurrency boundaries in tests.
private final class UnsafeSendableBox<T>: @unchecked Sendable {
    var value: T
    init(_ value: T) { self.value = value }
}
