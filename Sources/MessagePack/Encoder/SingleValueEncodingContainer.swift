// ===----------------------------------------------------------------------===//
// Copyright © 2024-2025 Apple Inc. and the Pkl project authors. All rights reserved.
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

extension _MessagePackEncoder {
    final class SingleValueContainer {
        fileprivate var canEncodeNewValue = true
        fileprivate func checkCanEncode(value: Any?) throws {
            guard self.canEncodeNewValue else {
                let context = EncodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription:
                    "Attempt to encode value through single value container when previously value already encoded."
                )
                throw EncodingError.invalidValue(value as Any, context)
            }
        }

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        private var storage: [UInt8] = []

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension _MessagePackEncoder.SingleValueContainer: SingleValueEncodingContainer {
    func encodeNil() throws {
        try checkCanEncode(value: nil)
        defer { self.canEncodeNewValue = false }

        self.storage.append(0xC0)
    }

    func encode(_ value: Bool) throws {
        try checkCanEncode(value: nil)
        defer { self.canEncodeNewValue = false }

        switch value {
        case false:
            self.storage.append(0xC2)
        case true:
            self.storage.append(0xC3)
        }
    }

    func encode(_ value: String) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        guard let data = value.data(using: .utf8) else {
            let context = EncodingError.Context(
                codingPath: self.codingPath, debugDescription: "Cannot encode string using UTF-8 encoding."
            )
            throw EncodingError.invalidValue(value, context)
        }
        let bytes = [UInt8](data)

        let length = bytes.count
        if let uint8 = UInt8(exactly: length) {
            if uint8 <= 31 {
                self.storage.append(0xA0 + uint8)
            } else {
                self.storage.append(0xD9)
                self.storage.append(contentsOf: uint8.bytes)
            }
        } else if let uint16 = UInt16(exactly: length) {
            self.storage.append(0xDA)
            self.storage.append(contentsOf: uint16.bytes)
        } else if let uint32 = UInt32(exactly: length) {
            self.storage.append(0xDB)
            self.storage.append(contentsOf: uint32.bytes)
        } else {
            let context = EncodingError.Context(
                codingPath: self.codingPath, debugDescription: "Cannot encode string with length \(length)."
            )
            throw EncodingError.invalidValue(value, context)
        }

        self.storage.append(contentsOf: bytes)
    }

    func encode(_ value: Double) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        self.storage.append(0xCB)
        self.storage.append(contentsOf: value.bitPattern.bytes)
    }

    func encode(_ value: Float) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        self.storage.append(0xCA)
        self.storage.append(contentsOf: value.bitPattern.bytes)
    }

    func encode(_ value: some BinaryInteger & Encodable) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        if value < 0 {
            if let int8 = Int8(exactly: value) {
                return try self.encode(int8)
            } else if let int16 = Int16(exactly: value) {
                return try self.encode(int16)
            } else if let int32 = Int32(exactly: value) {
                return try self.encode(int32)
            } else if let int64 = Int64(exactly: value) {
                return try self.encode(int64)
            }
        } else {
            if let uint8 = UInt8(exactly: value) {
                return try self.encode(uint8)
            } else if let uint16 = UInt16(exactly: value) {
                return try self.encode(uint16)
            } else if let uint32 = UInt32(exactly: value) {
                return try self.encode(uint32)
            } else if let uint64 = UInt64(exactly: value) {
                return try self.encode(uint64)
            }
        }

        let context = EncodingError.Context(
            codingPath: self.codingPath, debugDescription: "Cannot encode integer \(value)."
        )
        throw EncodingError.invalidValue(value, context)
    }

    func encode(_ value: Int8) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        if value >= 0, value <= 127 {
            self.storage.append(UInt8(value))
        } else if value < 0, value >= -31 {
            self.storage.append(0xE0 + (0x1F & UInt8(truncatingIfNeeded: value)))
        } else {
            self.storage.append(0xD0)
            self.storage.append(contentsOf: value.bytes)
        }
    }

    func encode(_ value: Int16) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        self.storage.append(0xD1)
        self.storage.append(contentsOf: value.bytes)
    }

    func encode(_ value: Int32) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        self.storage.append(0xD2)
        self.storage.append(contentsOf: value.bytes)
    }

    func encode(_ value: Int64) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        self.storage.append(0xD3)
        self.storage.append(contentsOf: value.bytes)
    }

    func encode(_ value: UInt8) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        if value <= 127 {
            self.storage.append(value)
        } else {
            self.storage.append(0xCC)
            self.storage.append(contentsOf: value.bytes)
        }
    }

    func encode(_ value: UInt16) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        self.storage.append(0xCD)
        self.storage.append(contentsOf: value.bytes)
    }

    func encode(_ value: UInt32) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        self.storage.append(0xCE)
        self.storage.append(contentsOf: value.bytes)
    }

    func encode(_ value: UInt64) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        self.storage.append(0xCF)
        self.storage.append(contentsOf: value.bytes)
    }

    func encode(_ value: Date) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }

        let timeInterval = value.timeIntervalSince1970
        let (integral, fractional) = modf(timeInterval)

        let seconds = Int64(integral)
        let nanoseconds = UInt32(fractional * Double(NSEC_PER_SEC))

        if seconds < 0 || seconds > UInt32.max {
            self.storage.append(0xC7)
            self.storage.append(0x0C)
            self.storage.append(0xFF)
            self.storage.append(contentsOf: nanoseconds.bytes)
            self.storage.append(contentsOf: seconds.bytes)
        } else if nanoseconds > 0 {
            self.storage.append(0xD7)
            self.storage.append(0xFF)
            self.storage.append(contentsOf: ((UInt64(nanoseconds) << 34) + UInt64(seconds)).bytes)
        } else {
            self.storage.append(0xD6)
            self.storage.append(0xFF)
            self.storage.append(contentsOf: UInt32(seconds).bytes)
        }
    }

    func encode(_ value: Data) throws {
        let length = value.count
        if let uint8 = UInt8(exactly: length) {
            self.storage.append(0xC4)
            self.storage.append(uint8)
            self.storage.append(contentsOf: value)
        } else if let uint16 = UInt16(exactly: length) {
            self.storage.append(0xC5)
            self.storage.append(contentsOf: uint16.bytes)
            self.storage.append(contentsOf: value)
        } else if let uint32 = UInt32(exactly: length) {
            self.storage.append(0xC6)
            self.storage.append(contentsOf: uint32.bytes)
            self.storage.append(contentsOf: value)
        } else {
            let context = EncodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Cannot encode data of length \(value.count)."
            )
            throw EncodingError.invalidValue(value, context)
        }
    }

    func encode(_ value: [UInt8]) throws {
        let length = value.count
        if let uint8 = UInt8(exactly: length) {
            self.storage.append(0xC4)
            self.storage.append(uint8)
            self.storage.append(contentsOf: value)
        } else if let uint16 = UInt16(exactly: length) {
            self.storage.append(0xC5)
            self.storage.append(contentsOf: uint16.bytes)
            self.storage.append(contentsOf: value)
        } else if let uint32 = UInt32(exactly: length) {
            self.storage.append(0xC6)
            self.storage.append(contentsOf: uint32.bytes)
            self.storage.append(contentsOf: value)
        } else {
            let context = EncodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Cannot encode data of length \(value.count)."
            )
            throw EncodingError.invalidValue(value, context)
        }
    }

    func encode(_ value: URL) throws {
        try self.encode("\(value)")
    }

    func encode(_ value: some Encodable) throws {
        try checkCanEncode(value: value)
        defer { self.canEncodeNewValue = false }
        switch value {
        case let data as Data:
            try self.encode(data)
        case let date as Date:
            try self.encode(date)
        case let url as URL:
            try self.encode(url)
        case let bool as Bool:
            try self.encode(bool)
        case let str as String:
            try self.encode(str)
        case let double as Double:
            try self.encode(double)
        case let float as Float:
            try self.encode(float)
        case let int8 as Int8:
            try self.encode(int8)
        case let int16 as Int16:
            try self.encode(int16)
        case let int32 as Int32:
            try self.encode(int32)
        case let int64 as Int64:
            try self.encode(int64)
        case let uint8 as UInt8:
            try self.encode(uint8)
        case let uint16 as UInt16:
            try self.encode(uint16)
        case let uint32 as UInt32:
            try self.encode(uint32)
        case let uint64 as UInt64:
            try self.encode(uint64)
        case let num as any BinaryInteger & Encodable:
            try self.encode(num)
        case let bytes as [UInt8]:
            guard type(of: value) == [UInt8].self else {
                fallthrough
            }
            try self.encode(bytes)
        default:
            let writer: Writer = BufferWriter()
            let encoder = _MessagePackEncoder()
            encoder.userInfo = userInfo
            encoder.codingPath = codingPath
            try value.encode(to: encoder)
            try encoder.write(into: writer)
            let data = (writer as! BufferWriter).bytes
            self.storage.append(contentsOf: data)
        }
    }
}

extension _MessagePackEncoder.SingleValueContainer: _MessagePackEncodingContainer {
    func write(into: Writer) throws {
        _ = try storage.withUnsafeBytes { try into.write($0) }
    }
}
