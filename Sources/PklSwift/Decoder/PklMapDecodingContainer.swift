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
    /// Decoding container that handles `Map` and `Mapping`.
    class PklMapDecodingContainer<Key>: KeyedDecodingContainerProtocol where Key: CodingKey {
        public typealias Key = Key

        let entries: [(MessagePackValue, MessagePackValue)]

        let codingPath: [CodingKey]

        public init(
            value: [MessagePackValue],
            codingPath: [CodingKey]
        ) throws {
            self.codingPath = codingPath
            if value.count != 2 {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: codingPath,
                        debugDescription: "Malformed Pkl data; expected array length 2 but found \(value.count)"
                    )
                )
            }
            if case .map(let entries) = value[1] {
                self.entries = entries
            } else {
                throw DecodingError.typeMismatch(
                    [AnyHashable: Any].self,
                    .init(
                        codingPath: codingPath,
                        debugDescription:
                        "Malformed Pkl data; expected map type but got \(value.debugDescription)"
                    )
                )
            }
        }

        var allKeys: [Key] {
            self.entries.compactMap { Key(stringValue: $0.0.stringValue) }
        }

        struct KeyMessagePackValueEntry {
            let key: Key
            let value: MessagePackValue
        }

        var allEntries: [KeyMessagePackValueEntry] {
            self.entries.compactMap { kv in
                Key(stringValue: kv.0.stringValue).map { KeyMessagePackValueEntry(key: $0, value: kv.1) }
            }
        }

        var entriesKeyedByString: [String: MessagePackValue] {
            var result: [String: MessagePackValue] = [:]
            for (key, value) in self.entries {
                switch key {
                case .string(let key):
                    result[key] = value
                default:
                    result["\(key)"] = value
                }
            }
            return result
        }

        func contains(_ key: Key) -> Bool {
            self.entriesKeyedByString.contains { $0.key == key.stringValue }
        }

        func decodeNil(forKey key: Key) throws -> Bool {
            self.entriesKeyedByString[key.stringValue] == .nil
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
            for entry in self.allEntries {
                if entry.key.stringValue == key.stringValue { // TODO: not great, compare underlying value?
                    // special case for polymorphic types
                    if type == PklAny.self,
                       let value = try _PklDecoder.decodePolymorphic(entry.value, codingPath: codingPath) {
                        return value as! T
                    }
                    let decoder = try _PklDecoder(value: entry.value)
                    return try T(from: decoder)
                }
            }
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "Missing key \(key)"))
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws
            -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
            guard let value = entriesKeyedByString[key.stringValue] else {
                throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "Missing key \(key)"))
            }
            var nestedCodingPath = self.codingPath
            nestedCodingPath.append(key)
            return try _PklDecoder.getNestedKeyedContainer(
                keyedBy: type,
                value: value,
                codingPath: nestedCodingPath
            )
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            guard let value = entriesKeyedByString[key.stringValue] else {
                throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "Missing key \(key)"))
            }
            var nestedCodingPath = self.codingPath
            nestedCodingPath.append(key)
            switch value {
            case .array(let value):
                var nestedCodingPath = self.codingPath
                nestedCodingPath.append(key)
                return try PklUnkeyedDecodingContainer(value: value, codingPath: nestedCodingPath)
            default:
                throw DecodingError.typeMismatch(
                    [Any].self,
                    .init(
                        codingPath: self.codingPath,
                        debugDescription: "Expected property to have an array type, but got \(value.debugDataTypeDescription)"
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
