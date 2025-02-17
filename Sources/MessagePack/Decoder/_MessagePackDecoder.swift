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

final class _MessagePackDecoder: Decoder {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey: Any] = [:]

    var value: MessagePackValue

    init(value: MessagePackValue) {
        self.value = value
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
        where Key: CodingKey {
        switch self.value {
        case .map(let map):
            let container = _MessagePackDecoder.KeyedContainer<Key>(
                value: map, codingPath: self.codingPath, userInfo: self.userInfo
            )
            return KeyedDecodingContainer(container)
        case .int:
            let container = _MessagePackDecoder.KeyedSingleContainer<Key>(
                value: self.value, codingPath: self.codingPath, userInfo: self.userInfo
            )
            return KeyedDecodingContainer(container)
        default:
            throw DecodingError.typeMismatch(
                [(MessagePackValue, MessagePackValue)].self,
                DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription:
                    "Expected to decode \([(MessagePackValue, MessagePackValue)].self), but found \(self.value.debugDataTypeDescription) instead"
                )
            )
        }
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        switch self.value {
        case .array(let values):
            return UnkeyedContainer(
                value: values, codingPath: self.codingPath, userInfo: self.userInfo
            )
//        case .map(let values):
//            return UnkeyedContainerForMaps(
//                value: values, codingPath: codingPath, userInfo: userInfo
//            )
        case .map(let values):
            return MapUnkeyedContainer(
                value: values, codingPath: self.codingPath, userInfo: self.userInfo
            )
        default:
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription:
                "Expected to decode \([(MessagePackValue, MessagePackValue)].self), but got \(self.value.debugDataTypeDescription)"
            )
            throw DecodingError.typeMismatch([(MessagePackValue, MessagePackValue)].self, context)
        }
    }

    func singleValueContainer() -> SingleValueDecodingContainer {
        SingleValueContainer(value: self.value, codingPath: self.codingPath, userInfo: self.userInfo)
    }
}

protocol MessagePackDecodingContainer: AnyObject {
    var codingPath: [CodingKey] { get set }

    var userInfo: [CodingUserInfoKey: Any] { get }
}

extension MessagePackValue {
    func decodeInto<T>(_ typ: T.Type) throws -> T where T: Decodable {
        let decoder = _MessagePackDecoder(value: self)
        switch typ {
        case is Data.Type:
            let box = try Box<Data>(from: decoder)
            return box.value as! T
        case is Date.Type:
            let box = try Box<Date>(from: decoder)
            return box.value as! T
        case is [UInt8].Type:
            let box = try Box<[UInt8]>(from: decoder)
            return box.value as! T
        case is URL.Type:
            let box = try Box<URL>(from: decoder)
            return box.value as! T
        default:
            return try T(from: decoder)
        }
    }
}
