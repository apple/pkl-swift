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

extension _MessagePackEncoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        private var storage: [AnyCodingKey: _MessagePackEncodingContainer] = [:]

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            self.codingPath + [key]
        }

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension _MessagePackEncoder.KeyedContainer: KeyedEncodingContainerProtocol {
    func encodeNil(forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key)
        try container.encodeNil()
    }

    func encode(_ value: some Encodable, forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key)
        try container.encode(value)
    }

    private func nestedSingleValueContainer(forKey key: Key) -> SingleValueEncodingContainer {
        let container = _MessagePackEncoder.SingleValueContainer(
            codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo
        )
        self.storage[AnyCodingKey(key)] = container
        return container
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = _MessagePackEncoder.UnkeyedContainer(
            codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo
        )
        self.storage[AnyCodingKey(key)] = container

        return container
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key)
        -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = _MessagePackEncoder.KeyedContainer<NestedKey>(
            codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo
        )
        self.storage[AnyCodingKey(key)] = container

        return KeyedEncodingContainer(container)
    }

    func superEncoder() -> Encoder {
        fatalError("Unimplemented") // FIXME:
    }

    func superEncoder(forKey key: Key) -> Encoder {
        fatalError("Unimplemented") // FIXME:
    }
}

extension _MessagePackEncoder.KeyedContainer: _MessagePackEncodingContainer {
    func write(into: Writer) throws {
        let length = storage.count
        if let uint16 = UInt16(exactly: length) {
            if length <= 15 {
                _ = try into.write(0x80 + UInt8(length))
            } else {
                _ = try into.write(0xDE)
                _ = try into.write(uint16.bytes)
            }
        } else if let uint32 = UInt32(exactly: length) {
            _ = try into.write(0xDF)
            _ = try into.write(uint32.bytes)
        } else {
            fatalError()
        }

        for (key, container) in self.storage {
            let keyContainer = _MessagePackEncoder.SingleValueContainer(
                codingPath: self.codingPath, userInfo: self.userInfo
            )
            try keyContainer.encode(key.stringValue)
            try keyContainer.write(into: into)
            try container.write(into: into)
        }
    }
}
