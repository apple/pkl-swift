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

@testable import MessagePack

struct Person: Codable, Hashable {
    let name: String
    let age: Int
    let hobby: String?
}

class MessagePackDecodingTests: XCTestCase {
    private func decode<T>(_ type: T.Type, from bytes: [UInt8]) throws -> T where T: Decodable {
        let decoder = MessagePackDecoder(reader: BufferReader(bytes))
        return try decoder.decode(as: type)
    }

    func testDecodeNil() throws {
        let bytes: [UInt8] = [0xC0]
        let value = try decode(Int?.self, from: bytes)
        XCTAssertNil(value)
    }

    func testDecodeFalse() throws {
        let bytes: [UInt8] = [0xC2]
        let value = try decode(Bool.self, from: bytes)
        XCTAssertEqual(value, false)
    }

    func testDecodeTrue() throws {
        let bytes: [UInt8] = [0xC3]
        let value = try decode(Bool.self, from: bytes)
        XCTAssertEqual(value, true)
    }

    func testDecodeFixInt() throws {
        let bytes: [UInt8] = [0x2A]
        let value = try decode(Int.self, from: bytes)
        XCTAssertEqual(value, 42)
    }

    func testDecodeNegativeFixInt() throws {
        let bytes: [UInt8] = [0xFF]
        let value = try decode(Int.self, from: bytes)
        XCTAssertEqual(value, -1)
    }

    func testDecodeUInt8() throws {
        let bytes: [UInt8] = [0xCC, 0xFF]
        let value = try decode(UInt8.self, from: bytes)
        XCTAssertEqual(value, UInt8.max)
    }

    func testDecodeUInt16() throws {
        let bytes: [UInt8] = [0xCD, 0xFF, 0xFF]
        let value = try decode(UInt16.self, from: bytes)
        XCTAssertEqual(value, UInt16.max)
    }

    func testDecodeUInt32() throws {
        let bytes: [UInt8] = [0xCE, 0xFF, 0xFF, 0xFF, 0xFF]
        let value = try decode(UInt32.self, from: bytes)
        XCTAssertEqual(value, UInt32.max)
    }

    func testDecodeUInt64() throws {
        let bytes: [UInt8] = [0xCF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
        let value = try decode(UInt64.self, from: bytes)
        XCTAssertEqual(value, UInt64.max)
    }

    func testDecodeInt8() throws {
        let bytes: [UInt8] = [0xD0, 0x80]
        let value = try decode(Int8.self, from: bytes)
        XCTAssertEqual(value, Int8.min)
    }

    func testDecodeInt16() throws {
        let bytes: [UInt8] = [0xD1, 0x80, 0x00]
        let value = try decode(Int16.self, from: bytes)
        XCTAssertEqual(value, Int16.min)
    }

    func testDecodeInt32() throws {
        let bytes: [UInt8] = [0xD2, 0x80, 0x00, 0x00, 0x00]
        let value = try decode(Int32.self, from: bytes)
        XCTAssertEqual(value, Int32.min)
    }

    func testDecodeInt64() throws {
        let bytes: [UInt8] = [0xD3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        let value = try decode(Int64.self, from: bytes)
        XCTAssertEqual(value, Int64.min)
    }

    func testDecodeUInt() throws {
        let bytes: [UInt8] = [0xCC, 0x80]
        let value = try decode(Int.self, from: bytes)
        XCTAssertEqual(value, 128)
    }

    func testDecodeFloat() throws {
        let bytes: [UInt8] = [0xCA, 0x40, 0x48, 0xF5, 0xC3]
        let value = try decode(Float.self, from: bytes)
        XCTAssertEqual(value, 3.14)
    }

    func testDecodeDouble() throws {
        let bytes: [UInt8] = [0xCB, 0x40, 0x09, 0x21, 0xF9, 0xF0, 0x1B, 0x86, 0x6E]
        let value = try decode(Double.self, from: bytes)
        XCTAssertEqual(value, 3.14159)
    }

    func testDecodeFixedArray() throws {
        let bytes: [UInt8] = [0x93, 0x01, 0x02, 0x03]
        let value = try decode([Int].self, from: bytes)
        XCTAssertEqual(value, [1, 2, 3])
    }

    func testDecodeVariableArray() throws {
        let bytes: [UInt8] = [0xDC] + [0x00, 0x10] + Array(0x01...0x10)
        let value = try decode([Int].self, from: bytes)
        XCTAssertEqual(value, Array(1...16))
    }

    func testDecodeFixedDictionary() throws {
        let bytes: [UInt8] = [0x83, 0xA1, 0x62, 0x02, 0xA1, 0x61, 0x01, 0xA1, 0x63, 0x03]
        let value = try decode([String: Int].self, from: bytes)
        XCTAssertEqual(value, ["a": 1, "b": 2, "c": 3])
    }

    func testDecodeData() throws {
        let bytes: [UInt8] = [0xC4, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F]
        let value = try decode(Data.self, from: bytes)
        XCTAssertEqual(value, "hello".data(using: .utf8))
    }

    func testDecodeUInt8Array() throws {
        let bytes: [UInt8] = [0xC4, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F]
        let value = try decode([UInt8].self, from: bytes)
        XCTAssertEqual(value, [UInt8]("hello".data(using: .utf8)!))
    }

    func testDecodeDate() throws {
        let bytes: [UInt8] = [0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01]
        let date = Date(timeIntervalSince1970: 1)
        let value = try decode(Date.self, from: bytes)
        XCTAssertEqual(value, date)
    }

    func testDecodeDistantPast() throws {
        let bytes: [UInt8] = [
            0xC7, 0x0C, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xF1, 0x88, 0x6B, 0x66, 0x00,
        ]
        let date = Date.distantPast
        let value = try decode(Date.self, from: bytes)
        XCTAssertEqual(value, date)
    }

    func testDecodeDistantFuture() throws {
        let bytes: [UInt8] = [
            0xC7, 0x0C, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0xEC, 0x31, 0x88, 0x00,
        ]
        let date = Date.distantFuture
        let value = try decode(Date.self, from: bytes)
        XCTAssertEqual(value, date)
    }

    func testDecodeFixArray() throws {
        let bytes: [UInt8] = [0x95, 0x01, 0x02, 0x03, 0x04, 0x05]
        let decoded = try decode([Int].self, from: bytes)
        XCTAssertEqual([1, 2, 3, 4, 5], decoded)
    }

    func testDecodeArray16() throws {
        let bytes: [UInt8] = [
            0xDC, 0x00, 0x21, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C,
            0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B,
            0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x21,
        ]
        let decoded = try decode([Int].self, from: bytes)
        XCTAssertEqual(Array(1...33), decoded)
    }

    func testDecodeArrayWithDate() throws {
        let bytes: [UInt8] = [0x91, 0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01]
        let date = Date(timeIntervalSince1970: 1)
        let value = try decode([Date].self, from: bytes)
        XCTAssertEqual(value, [date])
    }

    func testDecodeArrayWithBinary() throws {
        let bytes: [UInt8] = [0x91, 0xC4, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F]
        let helloBytes = [UInt8]("hello".data(using: .utf8)!)
        let value = try decode([[UInt8]].self, from: bytes)
        XCTAssertEqual(value, [helloBytes])
    }

    func testDecodeDictionaryWithDate() throws {
        let bytes: [UInt8] = [0x81, 0xA1, 0x31, 0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01]
        let date = Date(timeIntervalSince1970: 1)
        let value = try decode([String: Date].self, from: bytes)
        XCTAssertEqual(value, ["1": date])
    }

    func testDecodeDictionaryWithNonKeyString() throws {
        let writer = BufferWriter()
        let dict: [Person: Bool] = [Person(name: "Jerry", age: 11, hobby: nil): true]
        try MessagePackEncoder(writer: writer).encode([Person(name: "Jerry", age: 11, hobby: nil): true]
        )
        let decoded = try MessagePackDecoder(reader: BufferReader(writer.bytes)).decode(
            as: [Person: Bool].self)
        XCTAssertEqual(dict, decoded)
    }

    func testDecodeDecodable() throws {
        let bytes: [UInt8] = [
            0x83, 0xA4, 0x6E, 0x61, 0x6D, 0x65, 0xA6, 0x53, 0x68, 0x65, 0x6C, 0x6C, 0x79, 0xA3, 0x61,
            0x67, 0x65, 0x26, 0xA5, 0x68, 0x6F, 0x62, 0x62, 0x79, 0xC0,
        ]
        let decoded = try decode(Person.self, from: bytes)
        XCTAssertEqual(Person(name: "Shelly", age: 38, hobby: nil), decoded)
    }

    func testDecodeArrayWithDecodable() throws {
        let bytes: [UInt8] = [
            0x91, 0x83, 0xA5, 0x68, 0x6F, 0x62, 0x62, 0x79, 0xAD, 0x4D, 0x61, 0x6B, 0x69, 0x6E, 0x67,
            0x20, 0x70, 0x69, 0x7A, 0x7A, 0x61, 0x73, 0xA3, 0x61, 0x67, 0x65, 0x21, 0xA4, 0x6E, 0x61,
            0x6D, 0x65, 0xA3, 0x42, 0x6F, 0x62,
        ]
        let arrayOfPeople = [Person(name: "Bob", age: 33, hobby: "Making pizzas")]
        let decoded = try decode([Person].self, from: bytes)
        XCTAssertEqual(arrayOfPeople, decoded)
    }

    func testDecodeMapWithDecodable() throws {
        let bytes: [UInt8] = [
            0x82, 0xA6, 0x73, 0x68, 0x65, 0x6C, 0x6C, 0x79, 0x83, 0xA4, 0x6E, 0x61, 0x6D, 0x65, 0xA6,
            0x53, 0x68, 0x65, 0x6C, 0x6C, 0x79, 0xA3, 0x61, 0x67, 0x65, 0x26, 0xA5, 0x68, 0x6F, 0x62,
            0x62, 0x79, 0xC0, 0xA3, 0x62, 0x6F, 0x62, 0x83, 0xA4, 0x6E, 0x61, 0x6D, 0x65, 0xA3, 0x42,
            0x6F, 0x62, 0xA3, 0x61, 0x67, 0x65, 0x21, 0xA5, 0x68, 0x6F, 0x62, 0x62, 0x79, 0xAD, 0x4D,
            0x61, 0x6B, 0x69, 0x6E, 0x67, 0x20, 0x70, 0x69, 0x7A, 0x7A, 0x61, 0x73,
        ]
        let decoded = try decode([String: Person].self, from: bytes)
        XCTAssertEqual(
            [
                "shelly": Person(name: "Shelly", age: 38, hobby: nil),
                "bob": Person(name: "Bob", age: 33, hobby: "Making pizzas"),
            ], decoded
        )
    }

    func testDecodeURL() throws {
        let bytes: [UInt8] = [0xAF, 0x68, 0x74, 0x74, 0x70, 0x73, 0x3A, 0x2F, 0x2F, 0x66, 0x6F, 0x6F, 0x2F, 0x62, 0x61, 0x72]
        let decoded = try decode(URL.self, from: bytes)
        XCTAssertEqual(URL(string: "https://foo/bar"), decoded)
    }

    func testDecodeArrayWithURL() throws {
        let bytes: [UInt8] = [0x91, 0xAF, 0x68, 0x74, 0x74, 0x70, 0x73, 0x3A, 0x2F, 0x2F, 0x66, 0x6F, 0x6F, 0x2F, 0x62, 0x61, 0x72]
        let decoded = try decode([URL].self, from: bytes)
        XCTAssertEqual([URL(string: "https://foo/bar")], decoded)
    }

    func testDecodeMapWithMapKeysSimple() throws {
        let bytes: [UInt8] = [0x81, 0x01, 0x01]
        let decoded = try decode([Int: Int].self, from: bytes)
        XCTAssertEqual([1: 1], decoded)
    }

    func testDecodeMapWithMapKeysNested() throws {
        let bytes: [UInt8] = [0x81, 0x81, 0x01, 0x02, 0x03]
        let decoded = try decode([[Int: Int]: Int].self, from: bytes)
        XCTAssertEqual([[1: 2]: 3], decoded)
    }

    func testRawDecodeMessagePackValueMapWithMapKey() throws {
        let value =
            MessagePackValue.map([
                (
                    MessagePackValue.map([
                        (MessagePackValue.int(1), MessagePackValue.int(2)),
                    ]),
                    MessagePackValue.int(3)
                ),
                (
                    MessagePackValue.map([
                        (MessagePackValue.int(10), MessagePackValue.int(20)),
                    ]),
                    MessagePackValue.int(30)
                ),
            ])

        let decoded = try value.decodeInto([[Int: Int]: Int].self)
        XCTAssertEqual([[1: 2]: 3, [10: 20]: 30], decoded)
    }

    //  func testDecodeYams() throws {
//    let decoder = YAMLDecoder()
//    let encoded = """
//                  ? name: Barney
//                    age: 20
//                    hobby: Saxophone
//                  : 1
//                  """
//    let decoded = try decoder.decode([Person: Int].self, from: encoded)
//    XCTAssertEqual(decoded, [[1: 1]: 1])
    //  }
}
