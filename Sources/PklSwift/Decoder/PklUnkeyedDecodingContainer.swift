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

import MessagePack

extension _PklDecoder {
    class PklUnkeyedDecodingContainer: UnkeyedDecodingContainer {
        var codingPath: [CodingKey]

        var count: Int?

        var currentIndex: Int

        // either [members] or [bytes] are set
        var members: [MessagePackValue]?

        var bytes: [UInt8]?

        var isAtEnd: Bool {
            let length = self.members?.count ?? self.bytes!.count
            return self.currentIndex >= length
        }

        init(value: [MessagePackValue], codingPath: [CodingKey]) throws {
            func error(_ debugDescription: String) -> DecodingError {
                .dataCorrupted(.init(codingPath: codingPath, debugDescription: debugDescription))
            }

            guard value.count > 0 else {
                throw error("Expected at least a type marker, but got 0 values")
            }
            guard let pklType = try? value[0].decode(PklValueType.self) else {
                throw error("Failed to decode type marker from '\(value[0])'")
            }

            if pklType == .bytes {
                guard case .bin(let bytes) = value[1] else {
                    throw error("Expected binary but got \(value[1].debugDataTypeDescription)")
                }
                self.bytes = bytes
            } else if value.count == 2 {
                guard [.list, .listing, .set].contains(pklType) else {
                    throw error("Expected either list, listing, or set, but got \(pklType)")
                }
                guard case .array(let members) = value[1] else {
                    throw error("Expected an array at slot 2, but got \(value[1].debugDataTypeDescription)")
                }
                self.members = members
            } else {
                throw error("Expected 2 or 3 values, but found \(value.count)")
            }

            self.codingPath = codingPath
            self.currentIndex = 0
        }

        func decodeNil() throws -> Bool {
            if self.bytes != nil {
                return false
            }
            let members = self.members!
            defer { currentIndex += 1 }
            switch members[self.currentIndex] {
            case .nil: return true
            default: return false
            }
        }

        private func decodeBytes<T>(_: T.Type, _ bytes: [UInt8]) throws -> T where T: Decodable {
            let value = bytes[self.currentIndex]
            return value as! T
        }

        func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            defer { currentIndex += 1 }
            if let bytes = self.bytes {
                return try self.decodeBytes(type, bytes)
            }

            let value = self.members![self.currentIndex]

            // special case for polymorphic types
            if type == PklAny.self,
               let value = try _PklDecoder.decodePolymorphic(value, codingPath: codingPath) {
                return value as! T
            }
            return try T(from: _PklDecoder(value: value))
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<
            NestedKey
        > where NestedKey: CodingKey {
            if self.bytes != nil {
                throw self.error("Cannot decode byte into \(type) because the decoded value is a byte array.")
            }
            defer { currentIndex += 1 }
            let value = self.members![self.currentIndex]
            var nestedCodingPath = self.codingPath
            if let key = NestedKey(intValue: currentIndex) {
                nestedCodingPath.append(key)
            }
            return try _PklDecoder.getNestedKeyedContainer(
                keyedBy: type, value: value, codingPath: nestedCodingPath
            )
        }

        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            if self.bytes != nil {
                throw self.error("Cannot create nested UnkeyedDecodingContainer; the decoded value is a byte array.")
            }
            defer { currentIndex += 1 }
            let value = self.members![self.currentIndex]
            var nestedCodingPath = self.codingPath
            if let key = _PklKey(intValue: currentIndex) {
                nestedCodingPath.append(key)
            }
            if case .array(let value) = value {
                return try PklUnkeyedDecodingContainer(value: value, codingPath: nestedCodingPath)
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: nestedCodingPath, debugDescription: ""))
            }
        }

        func superDecoder() throws -> Decoder {
            fatalError("TODO")
        }

        private func error(_ debugDescription: String) -> DecodingError {
            .dataCorrupted(.init(codingPath: self.codingPath, debugDescription: debugDescription))
        }
    }
}
