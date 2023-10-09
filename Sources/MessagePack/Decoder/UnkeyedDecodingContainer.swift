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

extension _MessagePackDecoder {
    final class UnkeyedContainer {
        var codingPath: [CodingKey]

        var nestedCodingPath: [CodingKey] {
            self.codingPath + [AnyCodingKey(intValue: self.count ?? 0)!]
        }

        var userInfo: [CodingUserInfoKey: Any]

        lazy var count: Int? = self.value.count

        var value: [MessagePackValue]

        var currentIndex: Int = 0

        init(value: [MessagePackValue], codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.value = value
            self.codingPath = codingPath
            self.userInfo = userInfo
        }

        var isAtEnd: Bool {
            guard let count else {
                return true
            }
            return self.currentIndex >= count
        }

        func checkCanDecodeValue() throws {
            guard !self.isAtEnd else {
                throw DecodingError.dataCorruptedError(in: self, debugDescription: "Unexpected end of data")
            }
        }
    }
}

extension _MessagePackDecoder.UnkeyedContainer: UnkeyedDecodingContainer {
    func decodeNil() throws -> Bool {
        try checkCanDecodeValue()
        defer { currentIndex += 1 }
        switch value[currentIndex] {
        case .nil: return true
        default: return false
        }
    }

    func decode<T>(_ typ: T.Type) throws -> T where T: Decodable {
        try checkCanDecodeValue()
        defer {
            currentIndex += 1
        }
        let msgPackValue = value[currentIndex]
        return try msgPackValue.decodeInto(typ)
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try checkCanDecodeValue()
        defer { currentIndex += 1 }
        switch value[currentIndex] {
        case .array(let value):
            return _MessagePackDecoder.UnkeyedContainer(
                value: value, codingPath: nestedCodingPath, userInfo: userInfo
            )
        default:
            let context = DecodingError.Context(
                codingPath: codingPath,
                debugDescription:
                "Expected array type, but got \(value[currentIndex].debugDataTypeDescription)"
            )
            throw DecodingError.typeMismatch([MessagePackValue].self, context)
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        try checkCanDecodeValue()
        defer { currentIndex += 1 }

        switch value[currentIndex] {
        case .map(let value):
            let container = _MessagePackDecoder.KeyedContainer<NestedKey>(
                value: value, codingPath: nestedCodingPath, userInfo: userInfo
            )
            return KeyedDecodingContainer(container)
        default:
            let context = DecodingError.Context(
                codingPath: codingPath,
                debugDescription:
                "Expected \([(MessagePackValue, MessagePackValue)].self), but got \(value[currentIndex].debugDataTypeDescription)"
            )
            throw DecodingError.typeMismatch([(MessagePackValue, MessagePackValue)].self, context)
        }
    }

    func superDecoder() throws -> Decoder {
        fatalError("TODO")
    }
}
