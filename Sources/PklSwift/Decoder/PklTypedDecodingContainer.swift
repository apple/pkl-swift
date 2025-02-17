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
    fileprivate static func deriveProperties(
        _ objectMembers: [MessagePackValue], codingPath: [CodingKey]
    ) throws -> [String:
        MessagePackValue] {
        var result: [String: MessagePackValue] = [:]
        for member in objectMembers {
            if case .array(let parts) = member {
                let pklType = try parts[0].decode(PklValueType.self)
                if pklType != .objectMemberProperty {
                    throw DecodingError.dataCorrupted(
                        .init(
                            codingPath: codingPath,
                            debugDescription: "Expected property object member, but got \(pklType)"
                        ))
                }
                if case .string(let propertyName) = parts[1] {
                    result[propertyName] = parts[2]
                } else {
                    throw DecodingError.dataCorrupted(
                        .init(
                            codingPath: codingPath,
                            debugDescription:
                            "Expected second object property slot to be a string, but got \(parts[1].debugDataTypeDescription)"
                        ))
                }
            } else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: codingPath,
                        debugDescription:
                        "Expected object member to be an array, but got \(member.debugDataTypeDescription)"
                    ))
            }
        }
        return result
    }

    /// Decoding container specifically for Typed objects.
    class PklTypedDecodingContainer<Key>: KeyedDecodingContainerProtocol where Key: CodingKey {
        let codingPath: [CodingKey]

        let className: String

        let enclosingModuleURI: String

        let objectMembers: [MessagePackValue]

        let properties: [String: MessagePackValue]

        init(
            value: [MessagePackValue],
            codingPath: [CodingKey]
        ) throws {
            if value.count != 4 {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: codingPath,
                        debugDescription: "Expected 4 items in array, but found \(value.count)"
                    ))
            }
            self.className = try value[1].decode(String.self)
            self.enclosingModuleURI = try value[2].decode(String.self)
            if case .array(let members) = value[3] {
                self.objectMembers = members
            } else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: codingPath,
                        debugDescription:
                        "Expected an array of object members at slot 3, but got \(value[3].debugDataTypeDescription)"
                    ))
            }
            self.codingPath = codingPath
            self.properties = try deriveProperties(self.objectMembers, codingPath: codingPath)
        }

        var allKeys: [Key] {
            var result: [Key] = []
            for (propertyName, _) in self.properties {
                if let key = Key(stringValue: propertyName) {
                    result.append(key)
                }
            }
            return result
        }

        func contains(_ key: Key) -> Bool {
            self.properties.contains(where: { $0.key == key.stringValue })
        }

        func decodeNil(forKey key: Key) throws -> Bool {
            switch self.properties[key.stringValue] {
            case .nil: return true
            default: return false
            }
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
            guard let propertyValue = properties[key.stringValue] else {
                throw DecodingError.dataCorruptedError(
                    forKey: key, in: self, debugDescription: "Missing key \(key)"
                )
            }

            // special case for polymorphic types
            if type == PklAny.self,
               let value = try _PklDecoder.decodePolymorphic(propertyValue, codingPath: codingPath) {
                return value as! T
            }
            let decoder = try _PklDecoder(value: propertyValue)
            return try T(from: decoder)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws
            -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
            guard let propertyValue = properties[key.stringValue] else {
                throw DecodingError.dataCorruptedError(
                    forKey: key, in: self, debugDescription: "Missing key \(key)"
                )
            }
            var nestedCodingPath = self.codingPath
            nestedCodingPath.append(key)
            return try _PklDecoder.getNestedKeyedContainer(
                keyedBy: type, value: propertyValue, codingPath: nestedCodingPath
            )
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            guard let propertyValue = properties[key.stringValue] else {
                throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "Missing key \(key)"))
            }
            switch propertyValue {
            case .array(let value):
                var nestedCodingPath = self.codingPath
                nestedCodingPath.append(key)
                return try PklUnkeyedDecodingContainer(value: value, codingPath: self.codingPath)
            default:
                throw DecodingError.typeMismatch(
                    [Any].self,
                    .init(
                        codingPath: self.codingPath,
                        debugDescription: "Expected property to have an array type, but got \(propertyValue.debugDataTypeDescription)"
                    )
                )
            }
        }

        func superDecoder() throws -> Decoder {
            fatalError("TODO")
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            fatalError("TODO")
        }
    }
}
