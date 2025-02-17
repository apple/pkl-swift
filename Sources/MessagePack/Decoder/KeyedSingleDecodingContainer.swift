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

extension _MessagePackDecoder {
    final class KeyedSingleContainer<Key> where Key: CodingKey {
        var value: MessagePackValue
        var index: Int
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            self.codingPath + [key]
        }

        init(
            value: MessagePackValue,
            codingPath: [CodingKey],
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

extension _MessagePackDecoder.KeyedSingleContainer: KeyedDecodingContainerProtocol {
    var allKeys: [Key] {
        [Key(intValue: 0)!]
    }

    func contains(_ key: Key) -> Bool {
        key.intValue == 0
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        self.value == MessagePackValue.nil
    }

    func decode<T>(_ typ: T.Type, forKey key: Key) throws -> T where T: Decodable {
        _ = self.value.getAs(T.self) // FIXME: make optional

        let context = DecodingError.Context(
            codingPath: codingPath, debugDescription: "key not found: \(key)"
        )
        throw DecodingError.keyNotFound(key, context)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError("\(#function)")
    }

    func nestedContainer<NestedKey>(keyedBy nestedKeyType: NestedKey.Type, forKey key: Key) throws
        -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        fatalError("\(#function)")
    }

    func superDecoder() throws -> Decoder {
        fatalError("\(#function)")
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError("\(#function)")
    }
}
