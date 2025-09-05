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

import Foundation

/// A decoder for [MessagePack](https://msgpack.org/index.html).
///
/// Supports ``Decodable``, and reads as-needed from ``Reader``.
public final class MessagePackDecoder {
    private var reader: PeekableReader

    /// A dictionary you can use to customize the decoding process
    /// by providing contextual information.
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    public init(reader: Reader) {
        self.reader = PeekableReader(reader: reader)
    }

    public func decodeGeneric() throws -> MessagePackValue {
        let code = try reader.peek()
        switch code {
        case .nil:
            // advance the cursor
            _ = try self.readByte()
            return MessagePackValue.nil
        case .true, .false: return try MessagePackValue.bool(self.decodeBool())
        case let c where c.isFixint(): return try MessagePackValue.int(Int(self.readByte()))
        case let c where c.isFixedArray(): fallthrough
        case .array16, .array32: return try MessagePackValue.array(self.decodeArrayGeneric())
        case let c where c.isFixedMap(): fallthrough
        case .map16, .map32: return try MessagePackValue.map(self.decodeMapGeneric())
        case let c where c.isNegativeFixint():
            return MessagePackValue.int(Int(exactly: Int8(bitPattern: code))!)
        case .uint8: return try MessagePackValue.int(self.decodeUInt8())
        case .uint16: return try MessagePackValue.int(self.decodeUInt16())
        case .uint32: return try MessagePackValue.int(self.decodeUInt32())
        case .uint64: return try MessagePackValue.int(self.decodeUInt64())
        case .int8: return try MessagePackValue.int(self.decodeInt8())
        case .int16: return try MessagePackValue.int(self.decodeInt16())
        case .int32: return try MessagePackValue.int(self.decodeInt32())
        case .int64: return try MessagePackValue.int(self.decodeInt64())
        case .float: return try MessagePackValue.float(self.decodeFloat())
        case .double: return try MessagePackValue.float(self.decodeDouble())
        case let c where c.isFixedString(): fallthrough
        case .str8, .str16, .str32: return try MessagePackValue.string(self.decodeString())
        case .timestamp32, .timestamp64, .timestamp96:
            return try MessagePackValue.timestamp(self.decodeDate())
        case .bin8, .bin16, .bin32: return try MessagePackValue.bin(self.decodeBinary())
        case .fixext1, .fixext2, .fixext4, .fixext8, .fixext16, .ext8, .ext16, .ext32:
            return try MessagePackValue.ext(self.decodeExtension())
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [], debugDescription: "Unknown msgpack format: \(code.toHex())"
                ))
        }
    }

    public func decode<T>(as type: T.Type) throws -> T where T: Decodable {
        let value = try decodeGeneric()
        let converted = try value.decodeInto(type)
        return converted
    }

    public func decodeBool() throws -> Bool {
        let code = try readByte()
        switch code {
        case .false: return false
        case .true: return true
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Invalid code for bool: \(code.toHex())"))
        }
    }

    public func decodeNil() throws -> Any? {
        let code = try readByte()
        if code == .nil {
            return nil
        }
        throw DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "Invalid code for nil: \(code.toHex())"))
    }

    public func decodeInt() throws -> Int {
        try self.decodeBinaryInteger()
    }

    public func decodeInt8() throws -> Int8 {
        try self.decodeBinaryInteger()
    }

    public func decodeInt16() throws -> Int16 {
        try self.decodeBinaryInteger()
    }

    public func decodeInt32() throws -> Int32 {
        try self.decodeBinaryInteger()
    }

    public func decodeInt64() throws -> Int64 {
        try self.decodeBinaryInteger()
    }

    public func decodeUInt8() throws -> UInt8 {
        try self.decodeBinaryInteger()
    }

    public func decodeUInt16() throws -> UInt16 {
        try self.decodeBinaryInteger()
    }

    public func decodeUInt32() throws -> UInt32 {
        try self.decodeBinaryInteger()
    }

    public func decodeUInt64() throws -> UInt64 {
        try self.decodeBinaryInteger()
    }

    public func decodeFloat() throws -> Float {
        try self.decodeFloatingPoint()
    }

    public func decodeDouble() throws -> Double {
        try self.decodeFloatingPoint()
    }

    public func decodeString() throws -> String {
        let code = try readByte()
        let length: Int
        switch code {
        case let c where c.isFixedString():
            length = Int(code - 0xA0)
        case UInt8.str8:
            length = try Int(self.read(UInt8.self))
        case UInt8.str16:
            length = try Int(self.read(UInt16.self))
        case UInt8.str32:
            length = try Int(self.read(UInt32.self))
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [], debugDescription: "Invalid format for String length: \(code.toHex())"
                ))
        }

        let bytes = try read(length)
        guard let string = String(bytes: bytes, encoding: .utf8) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [], debugDescription: "Unable to serialize bytes into UTF-8 formatted string"
                )
            )
        }

        return string
    }

    public func decodeDate() throws -> Date {
        let code = try readByte()
        var seconds: TimeInterval
        var nanoseconds: TimeInterval

        switch code {
        case UInt8.timestamp32:
            _ = try self.read(Int8.self) // -1
            nanoseconds = 0
            seconds = try TimeInterval(self.read(UInt32.self))
        case UInt8.timestamp64:
            _ = try self.read(Int8.self) // -1
            let bitPattern = try read(UInt64.self)
            nanoseconds = TimeInterval(UInt32(bitPattern >> 34))
            seconds = TimeInterval(UInt32(bitPattern & 0x03_FFFF_FFFF))
        case UInt8.timestamp96:
            _ = try self.read(Int8.self) // 12
            _ = try self.read(Int8.self) // -1
            nanoseconds = try TimeInterval(self.read(UInt32.self))
            seconds = try TimeInterval(self.read(Int64.self))
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [], debugDescription: "Invalid format for date \(code.toHex())"
                ))
        }

        let timeInterval = TimeInterval(seconds) + nanoseconds / Double(NSEC_PER_SEC)

        return Date(timeIntervalSince1970: timeInterval)
    }

    public func decodeBinary() throws -> [UInt8] {
        let code = try readByte()
        let length: Int
        switch code {
        case UInt8.bin8:
            length = try Int(self.read(UInt8.self))
        case UInt8.bin16:
            length = try Int(self.read(UInt16.self))
        case UInt8.bin32:
            length = try Int(self.read(UInt32.self))
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [], debugDescription: "Invalid format for binary length \(code.toHex())"
                ))
        }

        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: length, alignment: 1)
        let readCount = try reader.read(into: buffer)
        if readCount < length {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: "Unexpected end of input"))
        }
        return Array(buffer)
    }

    public func decodeArrayGeneric() throws -> [MessagePackValue] {
        let length = try decodeArrayLength()
        var array: [MessagePackValue] = Array()
        for _ in 0..<length {
            try array.append(self.decodeGeneric())
        }
        return array
    }

    public func decodeArrayLength() throws -> Int {
        let code = try readByte()
        switch code {
        case let c where c.isFixedArray():
            return Int(code & 0x0F)
        case UInt8.array16:
            return try Int(self.read(UInt16.self))
        case UInt8.array32:
            return try Int(self.read(UInt32.self))
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [], debugDescription: "Invalid code \(code) for array header"
                ))
        }
    }

    public func decodeMapLength() throws -> Int {
        let code = try readByte()
        switch code {
        case let c where c.isFixedMap():
            return Int(code & 0x0F)
        case UInt8.map16:
            return try Int(self.read(UInt16.self))
        case UInt8.map32:
            return try Int(self.read(UInt32.self))
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [], debugDescription: "Invalid format \(code) for maps"
                ))
        }
    }

    public func decodeMapGeneric() throws -> [(MessagePackValue, MessagePackValue)] {
        let length = try decodeMapLength()
        var entries: [(MessagePackValue, MessagePackValue)] = []

        for _ in 0..<length {
            let key = try decodeGeneric()

            let value = try decodeGeneric()
            entries.append((key, value))
        }

        return entries
    }

    public func decodeExtensionLength() throws -> Int {
        let code = try readByte()
        switch code {
        case .fixext1: return 1
        case .fixext2: return 2
        case .fixext4: return 4
        case .fixext8: return 8
        case .fixext16: return 16
        case .ext8: return try Int(self.read(UInt8.self))
        case .ext16: return try Int(self.read(UInt16.self))
        case .ext32: return try Int(self.read(UInt32.self))
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [], debugDescription: "Invalid format \(code) for extensions"
                ))
        }
    }

    public func decodeExtension() throws -> (UInt8, [UInt8]) {
        let length = try decodeExtensionLength()
        let type = try readByte()
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: length, alignment: 1)
        let readCount = try reader.read(into: buffer)
        if readCount < length {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: "Unexpected end of input"))
        }
        return (type, Array(buffer))
    }

    private func decodeFloatingPoint<T>() throws -> T where T: BinaryFloatingPoint {
        let code = try readByte()
        let t: T?
        switch code {
        case UInt8.float:
            let bitPattern = try read(UInt32.self)
            let float = Float(bitPattern: bitPattern)
            t = T(exactly: float)
        case UInt8.double:
            let bitPattern = try read(UInt64.self)
            let double = Double(bitPattern: bitPattern)
            t = T(exactly: double)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [], debugDescription: "Invalid format for floating points: \(code.toHex())"
                ))
        }
        guard let t else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [], debugDescription: "Unable to decode bytes into BinaryFloatingPoint"
                ))
        }
        return t
    }

    private func decodeBinaryInteger<T>() throws -> T where T: BinaryInteger {
        let code = try readByte()

        var t: T?

        switch code {
        case let c where c.isFixint():
            t = T(code)
        case UInt8.uint8:
            t = try T(exactly: self.read(UInt8.self))
        case UInt8.uint16:
            t = try T(exactly: self.read(UInt16.self))
        case UInt8.uint32:
            t = try T(exactly: self.read(UInt32.self))
        case UInt8.uint64:
            t = try T(exactly: self.read(UInt64.self))
        case UInt8.int8:
            t = try T(exactly: self.read(Int8.self))
        case UInt8.int16:
            t = try T(exactly: self.read(Int16.self))
        case UInt8.int32:
            t = try T(exactly: self.read(Int32.self))
        case UInt8.int64:
            t = try T(exactly: self.read(Int64.self))
        case let c where c.isNegativeFixint():
            t = T(exactly: Int8(bitPattern: code))
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [], debugDescription: "Invalid format for int: \(code.toHex())"
                ))
        }

        guard let value = t else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [], debugDescription: "Unable to decode bytes into BinaryInteger"
                ))
        }
        return value
    }

    private func readByte() throws -> UInt8 {
        let out = UnsafeMutableRawBufferPointer.allocate(byteCount: 1, alignment: 1)
        defer { out.deallocate() }
        let readCount = try reader.read(into: out)
        if readCount == 0 {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: "Unexpected end of input"))
        }

        return out[0]
    }

    private func read(_ length: Int) throws -> [UInt8] {
        let out = UnsafeMutableRawBufferPointer.allocate(byteCount: length, alignment: 1)
        defer { out.deallocate() }
        let readCount = try reader.read(into: out)
        if readCount < length {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: "Unexpected end of input"))
        }
        return [UInt8](out)
    }

    private func read<T>(_: T.Type) throws -> T where T: FixedWidthInteger {
        let stride = MemoryLayout<T>.stride
        let bytes = try read(stride)
        return T(bytes: bytes)
    }
}

/// A generic representation of MessagePack values.
public enum MessagePackValue: @unchecked Sendable {
    case `nil`
    case bool(Bool)
    case int(any BinaryInteger)
    case float(any BinaryFloatingPoint)
    case string(String)
    case bin([UInt8])
    indirect case array([MessagePackValue])
    // list of tuples
    indirect case map([(MessagePackValue, MessagePackValue)])
    case ext((UInt8, [UInt8]))
    case timestamp(Date)
}

extension MessagePackValue {
    public var description: String {
        // We have to manually implement since otherwise it gets the value from CodingKey
        // TODO: refactor it as CodingKeyRepresentable
        switch self {
        case .nil:
            return "nil"
        case .bool(let value):
            return ".bool(\(value))"
        case .int(let value):
            return ".int(\(value))"
        case .float(let value):
            return ".float(\(value))"
        case .string(let value):
            return ".string(\(value))"
        case .bin(let value):
            return ".bin(\(value))"
        case .array(let value):
            return ".array((\(value))"
        case .map(let value):
            return ".map(\(value))"
        case .ext(let value):
            return ".ext(\(value))"
        case .timestamp(let value):
            return ".timestamp(\(value))"
        }
    }
}

extension MessagePackValue {
    public func decode<T>(_: T.Type) throws -> T where T: Decodable {
        try T(from: _MessagePackDecoder(value: self))
    }
}

extension MessagePackValue {
    public var debugDataTypeDescription: String {
        switch self {
        case .array:
            return "an array"
        case .bool:
            return "bool"
        case .int:
            return "an integer"
        case .float:
            return "a float"
        case .string:
            return "a string"
        case .map:
            return "a dictionary"
        case .nil:
            return "null"
        case .bin:
            return "binary"
        case .ext:
            return "ext"
        case .timestamp:
            return "a timestamp"
        }
    }
}

extension UInt8 {
    fileprivate static let `nil`: UInt8 = 0xC0

    fileprivate static let `false`: UInt8 = 0xC2
    fileprivate static let `true`: UInt8 = 0xC3

    fileprivate static let float: UInt8 = 0xCA
    fileprivate static let double: UInt8 = 0xCB

    fileprivate static let uint8: UInt8 = 0xCC
    fileprivate static let uint16: UInt8 = 0xCD
    fileprivate static let uint32: UInt8 = 0xCE
    fileprivate static let uint64: UInt8 = 0xCF

    fileprivate static let int8: UInt8 = 0xD0
    fileprivate static let int16: UInt8 = 0xD1
    fileprivate static let int32: UInt8 = 0xD2
    fileprivate static let int64: UInt8 = 0xD3

    fileprivate static let str8: UInt8 = 0xD9
    fileprivate static let str16: UInt8 = 0xDA
    fileprivate static let str32: UInt8 = 0xDB

    fileprivate static let fixext1: UInt8 = 0xD4
    fileprivate static let fixext2: UInt8 = 0xD5
    fileprivate static let fixext4: UInt8 = 0xD6
    fileprivate static let fixext8: UInt8 = 0xD7
    fileprivate static let fixext16: UInt8 = 0xD8
    fileprivate static let ext8: UInt8 = 0xC7
    fileprivate static let ext16: UInt8 = 0xC8
    fileprivate static let ext32: UInt8 = 0xC9

    fileprivate static let timestamp32: UInt8 = 0xD6
    fileprivate static let timestamp64: UInt8 = 0xD7
    fileprivate static let timestamp96: UInt8 = 0xC7

    fileprivate static let bin8: UInt8 = 0xC4
    fileprivate static let bin16: UInt8 = 0xC5
    fileprivate static let bin32: UInt8 = 0xC6

    fileprivate static let array16: UInt8 = 0xDC
    fileprivate static let array32: UInt8 = 0xDD

    fileprivate static let map16: UInt8 = 0xDE
    fileprivate static let map32: UInt8 = 0xDF

    fileprivate func isFixint() -> Bool {
        0x00...0x7F ~= self
    }

    fileprivate func isNegativeFixint() -> Bool {
        0xE0...0xFF ~= self
    }

    fileprivate func isFixedString() -> Bool {
        0xA0...0xBF ~= self
    }

    fileprivate func isFixedArray() -> Bool {
        0x90...0x9F ~= self
    }

    fileprivate func isFixedMap() -> Bool {
        0x80...0x8F ~= self
    }
}

extension UInt8 {
    func toHex() -> String {
        "0x\(String(format:"%02X", self)))"
    }
}
