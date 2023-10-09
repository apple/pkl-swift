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

import Foundation

extension MessagePackValue: CodingKey {
    public var stringValue: String {
        switch self {
        case .nil:
            return "nil"
        case .bool(let value):
            return "\(value)"
        case .int(let value):
            return "\(value)"
        case .float(let value):
            return "\(value)"
        case .string(let value):
            return "\(value)"
        case .bin(let value):
            return "\(value)"
        case .array(let value):
            return "\(value)"
        case .map(let value):
            var map: [String: String] = [:]
            for (k, v) in value {
                map[k.stringValue] = v.stringValue
            }
            return "\(map)"
        case .ext(let value):
            return "\(value)"
        case .timestamp(let value):
            return "\(value)"
        }
    }

    public init?(stringValue: String) {
        fatalError("Use init(value:) instead")
    }

    public var intValue: Int? {
        nil
    }

    public init?(intValue: Int) {
        fatalError("Use init(value:) instead")
    }
}

extension MessagePackValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .nil:
            "nil".hash(into: &hasher)
        case .bool(let value):
            value.hash(into: &hasher)
        case .int(let value):
            value.hash(into: &hasher)
        case .float(let value):
            value.hash(into: &hasher)
        case .string(let value):
            value.hash(into: &hasher)
        case .bin(let value):
            value.hash(into: &hasher)
        case .array(let values):
            for v in values {
                v.hash(into: &hasher)
            }
        case .map(let values):
            for (k, v) in values {
                k.hash(into: &hasher)
                v.hash(into: &hasher)
            }
        case .ext(let value):
            value.0.hash(into: &hasher)
            for v in value.1 {
                v.hash(into: &hasher)
            }
        case .timestamp(let value):
            value.hash(into: &hasher)
        }
    }

    public static func ==(lhs: MessagePackValue, rhs: MessagePackValue) -> Bool {
        switch (lhs, rhs) {
        case (.nil, .nil):
            return true
        case (.bool(let l), .bool(let r)):
            return l == r
        case (.int(let l), .int(let r)):
            return "\(l)" == "\(r)" // FIXME: hack
        case (.float(let l), .float(let r)):
            return "\(l)" == "\(r)" // FIXME: hack
        case (.string(let l), .string(let r)):
            return l == r
        case (.bin(let l), .bin(let r)):
            return l == r
        case (.array(let ls), .array(let rs)):
            return ls == rs
        case (.map(let ls), .map(let rs)):
            guard ls.count == rs.count else {
                return false
            }
            for i in 0..<rs.count {
                let l = ls[i]
                let r = rs[i]
                guard l.0 == r.0 else {
                    return false
                }
                guard l.1 == r.1 else {
                    return false
                }
                continue
            }
            return true
        case (.ext(let l), .ext(let r)):
            return l == r
        case (.timestamp(let l), .timestamp(let r)):
            return l == r
        default:
            return false
        }
    }
}

extension MessagePackValue {
    func getAs<T>(_: T.Type) -> T {
        switch self {
        case .nil:
            fatalError("nil")
        case .bool(let value):
            if T.self is Bool.Type {
                return value as! T
            } else {
                fatalError("Cannot convert \(self) to \(T.self)")
            }
        case .int(let value):
            if T.self is Int.Type {
                return value as! T
            } else {
                fatalError("Cannot convert \(self) to \(T.self)")
            }
        case .float(let value):
            if T.self is Float.Type {
                return value as! T
            } else {
                fatalError("Cannot convert \(self) to \(T.self)")
            }
        case .string(let value):
            if T.self is String.Type {
                return value as! T
            } else {
                fatalError("Cannot convert \(self) to \(T.self)")
            }
        case .bin(let value):
            if T.self is [UInt8].Type {
                return value as! T
            } else {
                fatalError("Cannot convert \(self) to \(T.self)")
            }
        case .array(let values):
            if T.self is [MessagePackValue].Type {
                return values as! T
            } else {
                fatalError("Cannot convert \(self) to \(T.self)")
            }
        case .map(let values):
            if T.self is [MessagePackValue: MessagePackValue].Type {
                return values as! T
            } else {
                fatalError("Cannot convert \(self) to \(T.self)")
            }
        case .ext:
            // TODO: implement this?
            fatalError("Cannot convert \(self) to \(T.self)")

        case .timestamp:
            // TODO: implement this?
            fatalError("Cannot convert \(self) to \(T.self)")
        }
    }
}

extension _MessagePackDecoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        var value: [(MessagePackValue, MessagePackValue)]
        var index: Int
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            self.codingPath + [key]
        }

        init(
            value: [(MessagePackValue, MessagePackValue)], codingPath: [CodingKey],
            userInfo: [CodingUserInfoKey: Any]
        ) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.value = value
            self.index = 0
        }

        func checkCanDecodeValue(forKey key: Key) throws {
            guard contains(key) else {
                let context = DecodingError.Context(
                    codingPath: self.codingPath, debugDescription: "key not found: \(key)"
                )
                throw DecodingError.keyNotFound(key, context)
            }
        }
    }
}

extension _MessagePackDecoder.KeyedContainer: KeyedDecodingContainerProtocol {
    var strMap: [String: MessagePackValue] {
        var result: [String: MessagePackValue] = [:]
        for (key, value) in value {
            switch key {
            case .string(let key):
                result[key] = value
            default:
                result["\(key)"] = value
            }
        }
        return result
    }

    var allKeys: [Key] {
        self.value.compactMap { Key(stringValue: $0.0.stringValue) }
    }

    struct KeyMessagePackValueEntry {
        let key: Key
        let value: MessagePackValue
    }

    var allEntries: [KeyMessagePackValueEntry] {
        let keys = self.value.compactMap { kv in
            Key(stringValue: kv.0.stringValue).map { KeyMessagePackValueEntry(key: $0, value: kv.1) }
        }
        return keys
    }

    func contains(_ key: Key) -> Bool {
        self.strMap.contains { $0.key == key.stringValue }
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        switch self.strMap[key.stringValue] {
        case .nil:
            return true
        default:
            return false
        }
    }

    func decode<T>(_ typ: T.Type, forKey key: Key) throws -> T where T: Decodable {
        defer {
            index += 1
        }

        for entry in self.allEntries {
            if entry.key.stringValue == key.stringValue { // TODO: not great, compare underlying value?
                return try entry.value.decodeInto(typ)
            }
        }

        let context = DecodingError.Context(
            codingPath: codingPath, debugDescription: "key not found: \(key)"
        )
        throw DecodingError.keyNotFound(key, context)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try checkCanDecodeValue(forKey: key)
        guard let msgPackValue = strMap[key.stringValue] else {
            let context = DecodingError.Context(
                codingPath: codingPath, debugDescription: "key not found: \(key)"
            )
            throw DecodingError.keyNotFound(key, context)
        }
        switch msgPackValue {
        case .array(let msgPackValue):
            return _MessagePackDecoder.UnkeyedContainer(
                value: msgPackValue, codingPath: nestedCodingPath(forKey: key), userInfo: userInfo
            )
        default:
            let context = DecodingError.Context(
                codingPath: codingPath, debugDescription: "type mismatch: \(key)"
            )
            throw DecodingError.typeMismatch(type(of: msgPackValue), context)
        }
    }

    func nestedContainer<NestedKey>(keyedBy nestedKeyType: NestedKey.Type, forKey key: Key) throws
        -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        try checkCanDecodeValue(forKey: key)

        guard let msgPackValue = strMap[key.stringValue] else {
            let context = DecodingError.Context(
                codingPath: codingPath, debugDescription: "key not found: \(key)"
            )
            throw DecodingError.keyNotFound(key, context)
        }

        switch msgPackValue {
        case .map(let msgPackValue):
            let container = _MessagePackDecoder.KeyedContainer<NestedKey>(
                value: msgPackValue,
                codingPath: nestedCodingPath(forKey: key),
                userInfo: userInfo
            )
            return KeyedDecodingContainer(container)
        default:
            let context = DecodingError.Context(
                codingPath: codingPath, debugDescription: "type mismatch: \(key)"
            )
            throw DecodingError.typeMismatch(type(of: msgPackValue), context)
        }
    }

    func superDecoder() throws -> Decoder {
        fatalError("TODO fixme")
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError("TODO fixme")
    }
}
