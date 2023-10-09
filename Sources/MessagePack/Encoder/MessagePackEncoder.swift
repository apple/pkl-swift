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

/// An object that encodes instances of a data type as MessagePack objects.
public final class MessagePackEncoder {
    var writer: Writer

    /// A dictionary you use to customize the encoding process
    /// by providing contextual information.
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    public init(writer: Writer) {
        self.writer = writer
    }

    ///  Returns a MessagePack-encoded representation of the value you supply.
    ///
    ///  - Parameters:
    ///     - value: The value to encode as MessagePack.
    ///  - Throws: `EncodingError.invalidValue(_:_:)`
    ///             if the value can't be encoded as a MessagePack object.
    ///
    /// Encodes [value] into the output stream
    public func encode(_ value: some Encodable) throws {
        let encoder = _MessagePackEncoder()
        encoder.userInfo = self.userInfo
        switch value {
        case let data as Data:
            try Box<Data>(data).encode(to: encoder)
        case let date as Date:
            try Box<Date>(date).encode(to: encoder)
        case let bytes as [UInt8]:
            try Box<[UInt8]>(bytes).encode(to: encoder)
        case let url as URL:
            try Box<URL>(url).encode(to: encoder)
        default:
            try value.encode(to: encoder)
        }
        try encoder.write(into: self.writer)
    }

    public func encodeArrayHeader(_ length: Int) throws {
        // let length = self.storage.count
        if let uint16 = UInt16(exactly: length) {
            if uint16 <= 15 {
                try self.writer.write(UInt8(0x90 + uint16))
            } else {
                try self.writer.write(0xDC)
                try self.writer.write(uint16.bytes)
            }
        } else if let uint32 = UInt32(exactly: length) {
            try self.writer.write(0xDD)
            try self.writer.write(uint32.bytes)
        } else {
            fatalError()
        }
    }
}

protocol _MessagePackEncodingContainer {
    func write(into: Writer) throws
}

class _MessagePackEncoder {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey: Any] = [:]

    private var container: _MessagePackEncodingContainer?

    func write(into: Writer) throws {
        try self.container?.write(into: into)
    }
}

extension _MessagePackEncoder: Encoder {
    fileprivate func assertCanCreateContainer() {
        precondition(self.container == nil)
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        self.assertCanCreateContainer()

        let container = KeyedContainer<Key>(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container

        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        self.assertCanCreateContainer()

        let container = UnkeyedContainer(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container

        return container
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        self.assertCanCreateContainer()

        let container = SingleValueContainer(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container

        return container
    }
}
