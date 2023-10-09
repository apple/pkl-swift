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

extension _MessagePackEncoder {
    final class UnkeyedContainer {
        private var storage: [_MessagePackEncodingContainer] = []

        var count: Int {
            self.storage.count
        }

        var codingPath: [CodingKey]

        var nestedCodingPath: [CodingKey] {
            self.codingPath + [AnyCodingKey(intValue: self.count)!]
        }

        var userInfo: [CodingUserInfoKey: Any]

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension _MessagePackEncoder.UnkeyedContainer: UnkeyedEncodingContainer {
    func encodeNil() throws {
        var container = self.nestedSingleValueContainer()
        try container.encodeNil()
    }

    func encode(_ value: some Encodable) throws {
        var container = self.nestedSingleValueContainer()
        try container.encode(value)
    }

    private func nestedSingleValueContainer() -> SingleValueEncodingContainer {
        let container = _MessagePackEncoder.SingleValueContainer(
            codingPath: self.nestedCodingPath, userInfo: self.userInfo
        )
        self.storage.append(container)

        return container
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<
        NestedKey
    > where NestedKey: CodingKey {
        let container = _MessagePackEncoder.KeyedContainer<NestedKey>(
            codingPath: self.nestedCodingPath, userInfo: self.userInfo
        )
        self.storage.append(container)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let container = _MessagePackEncoder.UnkeyedContainer(
            codingPath: self.nestedCodingPath, userInfo: self.userInfo
        )
        self.storage.append(container)

        return container
    }

    func superEncoder() -> Encoder {
        fatalError("Unimplemented") // FIXME:
    }
}

extension _MessagePackEncoder.UnkeyedContainer: _MessagePackEncodingContainer {
    func write(into: Writer) throws {
        let length = self.storage.count
        if let uint16 = UInt16(exactly: length) {
            if uint16 <= 15 {
                _ = try into.write(UInt8(0x90 + uint16))
            } else {
                _ = try into.write(0xDC)
                _ = try into.write(uint16.bytes)
            }
        } else if let uint32 = UInt32(exactly: length) {
            _ = try into.write(0xDD)
            _ = try into.write(uint32.bytes)
        } else {
            fatalError()
        }

        for container in storage {
            try container.write(into: into)
        }
    }
}
