// ===----------------------------------------------------------------------===//
// Copyright © 2023 Apple Inc. and the Pkl project authors. All rights reserved.
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

import XCTest

@testable import MessagePack

final class MessagePackEncodingTests: XCTestCase {
    var writer: BufferWriter?
    var encoder: MessagePackEncoder!

    func encode(_ value: some Encodable) throws -> [UInt8] {
        try self.encoder.encode(value)
        return self.writer!.bytes
    }

    override func setUp() {
        self.writer = BufferWriter()
        self.encoder = MessagePackEncoder(writer: self.writer!)
    }

    func testEncodeNil() throws {
        let value = try self.encode(nil as Int?)
        XCTAssertEqual(value, [0xC0])
    }

    func testEncodeFalse() throws {
        let value = try self.encode(false)
        XCTAssertEqual(value, [0xC2])
    }

    func testEncodeTrue() throws {
        let value = try self.encode(true)
        XCTAssertEqual(value, [0xC3])
    }

    func testEncodeInt() throws {
        let value = try self.encode(42 as Int)
        XCTAssertEqual(value, [0x2A])
    }

    func testEncodeUInt() throws {
        let value = try self.encode(128 as UInt)
        XCTAssertEqual(value, [0xCC, 0x80])
    }

    func testEncodeFloat() throws {
        let value = try self.encode(3.14 as Float)
        XCTAssertEqual(value, [0xCA, 0x40, 0x48, 0xF5, 0xC3])
    }

    func testEncodeDouble() throws {
        let value = try self.encode(3.14159 as Double)
        XCTAssertEqual(value, [0xCB, 0x40, 0x09, 0x21, 0xF9, 0xF0, 0x1B, 0x86, 0x6E])
    }

    func testEncodeString() throws {
        let value = try self.encode("hello")
        XCTAssertEqual(value, [0xA5, 0x68, 0x65, 0x6C, 0x6C, 0x6F])
    }

    func testEncodeFixedArray() throws {
        let value = try self.encode([1, 2, 3])
        XCTAssertEqual(value, [0x93, 0x01, 0x02, 0x03])
    }

    func testEncodeVariableArray() throws {
        let value = try self.encode(Array(1...16))
        XCTAssertEqual(value, [0xDC] + [0x00, 0x10] + Array(0x01...0x10))
    }

    func testEncodeFixedDictionary() throws {
        let value = try self.encode(["a": 1])
        XCTAssertEqual(value, [0x81, 0xA1, 0x61, 0x01])
    }

    func testEncodeVariableDictionary() throws {
        let letters = "abcdefghijklmnopqrstuvwxyz".unicodeScalars
        let dictionary = Dictionary(uniqueKeysWithValues: zip(letters.map { String($0) }, 1...26))
        let value = try self.encode(dictionary)
        XCTAssertEqual(value.count, 81)
        XCTAssert(value.starts(with: [0xDE] + [0x00, 0x1A]))
    }

    func testEncodeData() throws {
        let data = "hello".data(using: .utf8)
        let value = try self.encode(data)
        XCTAssertEqual(value, [0xC4, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F])
    }

    func testEncodeDate() throws {
        let date = Date(timeIntervalSince1970: 1)
        let value = try self.encode(date)
        XCTAssertEqual(value, [0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01])
    }

    func testEncodeDistantPast() throws {
        let date = Date.distantPast
        let value = try self.encode(date)
        XCTAssertEqual(
            value,
            [
                0xC7, 0x0C, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xF1, 0x88, 0x6B, 0x66, 0x00,
            ]
        )
    }

    func testEncodeDistantFuture() throws {
        let date = Date.distantFuture
        let value = try self.encode(date)
        XCTAssertEqual(
            value,
            [
                0xC7, 0x0C, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0xEC, 0x31, 0x88, 0x00,
            ]
        )
    }

    func testEncodeArrayWithDate() throws {
        let date = Date(timeIntervalSince1970: 1)
        let value = try self.encode([date])
        XCTAssertEqual(value, [0x91, 0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01])
    }

    func testEncodeDictionaryWithDate() throws {
        let date = Date(timeIntervalSince1970: 1)
        let value = try self.encode(["1": date])
        XCTAssertEqual(value, [0x81, 0xA1, 0x31, 0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01])
    }

    func testEncodeURL() throws {
        let url = URL(string: "https://foo/bar")!
        let value = try self.encode(url)
        XCTAssertEqual(value, [0xAF, 0x68, 0x74, 0x74, 0x70, 0x73, 0x3A, 0x2F, 0x2F, 0x66, 0x6F, 0x6F, 0x2F, 0x62, 0x61, 0x72])
    }

    func testEncodeArrayWithURL() throws {
        let url = URL(string: "https://foo/bar")!
        let value = try self.encode([url])
        XCTAssertEqual(value, [0x91, 0xAF, 0x68, 0x74, 0x74, 0x70, 0x73, 0x3A, 0x2F, 0x2F, 0x66, 0x6F, 0x6F, 0x2F, 0x62, 0x61, 0x72])
    }
}
