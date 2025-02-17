//===----------------------------------------------------------------------===//
// Copyright © 2024-2025 Apple Inc. and the Pkl project authors. All rights reserved.
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

import XCTest

@testable import PklSwift

final class PklDecoderTests: XCTestCase {
    func testDecodeNil() throws {
        let bytes: [UInt8] = [0xC0]
        let value = try PklDecoder.decode(Int?.self, from: bytes)
        XCTAssertNil(value)
    }

    func testDecodeFalse() throws {
        let bytes: [UInt8] = [0xC2]
        let value = try PklDecoder.decode(Bool.self, from: bytes)
        XCTAssertEqual(value, false)
    }

    func testDecodeTrue() throws {
        let bytes: [UInt8] = [0xC3]
        let value = try PklDecoder.decode(Bool.self, from: bytes)
        XCTAssertEqual(value, true)
    }

    func testDecodeInt() throws {
        let bytes: [UInt8] = [0x2A]
        let value = try PklDecoder.decode(Int.self, from: bytes)
        XCTAssertEqual(value, 42)
    }

    func testDecodeString() throws {
        let bytes: [UInt8] = [
            0xD9, 0x27, 0x74, 0x68, 0x65, 0x20, 0x71, 0x75, 0x69, 0x63, 0x6B, 0x20, 0x66, 0x6F, 0x78,
            0x20, 0x6A, 0x75, 0x6D, 0x70, 0x65, 0x64, 0x20, 0x6F, 0x76, 0x65, 0x72, 0x20, 0x74, 0x68,
            0x65, 0x20, 0x6C, 0x61, 0x7A, 0x79, 0x20, 0x62, 0x65, 0x61, 0x72,
        ]
        let value = try PklDecoder.decode(String.self, from: bytes)
        XCTAssertEqual(value, "the quick fox jumped over the lazy bear")
    }

    struct Person: Decodable, Equatable, Hashable {
        let name: String
    }

    func testDecodeDecodable() throws {
        let bytes: [UInt8] = [
            0x94, 0x01, 0xB2, 0x50, 0x65, 0x72, 0x73, 0x6F, 0x6E, 0x23, 0x4D, 0x6F, 0x64, 0x75, 0x6C,
            0x65, 0x43, 0x6C, 0x61, 0x73, 0x73, 0xBA, 0x66, 0x69, 0x6C, 0x65, 0x3A, 0x2F, 0x2F, 0x2F,
            0x70, 0x61, 0x74, 0x68, 0x2F, 0x74, 0x6F, 0x2F, 0x70, 0x65, 0x72, 0x73, 0x6F, 0x6E, 0x2E,
            0x70, 0x63, 0x6C, 0x91, 0x93, 0x10, 0xA4, 0x6E, 0x61, 0x6D, 0x65, 0xA6, 0x42, 0x61, 0x72,
            0x6E, 0x65, 0x79,
        ]
        let value = try PklDecoder.decode(Person.self, from: bytes)
        XCTAssertEqual(value, Person(name: "Barney"))
    }

    func testDecodeListing() throws {
        let bytes: [UInt8] = [0x92, 0x04, 0x94, 0x01, 0x02, 0x03, 0x04]
        let value = try PklDecoder.decode([Int].self, from: bytes)
        XCTAssertEqual(value, [1, 2, 3, 4])
    }

    func testDecodeDataSize() throws {
        let bytes: [UInt8] = [
            0x93, 0x08, 0xCB, 0x40, 0x09, 0x21, 0xF9, 0xF0, 0x1B, 0x86, 0x6E, 0xA2, 0x6B, 0x62,
        ]
        let value = try PklDecoder.decode(DataSize.self, from: bytes)
        XCTAssertEqual(value, .kilobytes(3.14159))
    }

    func testDecodeDuration() throws {
        let bytes: [UInt8] = [
            0x93, 0x07, 0xCB, 0x40, 0x09, 0x21, 0xF9, 0xF0, 0x1B, 0x86, 0x6E, 0xA3, 0x6D, 0x69, 0x6E,
        ]
        let value = try PklDecoder.decode(Duration.self, from: bytes)
        XCTAssertEqual(value, .minutes(3.14159))
    }

    func testDecodeMap() throws {
        let bytes: [UInt8] = [
            0x92, 0x02, 0x81, 0x01, 0x01,
        ]
        let value = try PklDecoder.decode([Int: Int].self, from: bytes)
        XCTAssertEqual(value, [1: 1])
    }
}
