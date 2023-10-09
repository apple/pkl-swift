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

extension MessagePackValue {
    func flattened() -> [MessagePackValue] {
        switch self {
        case .nil, .bool, .int, .float, .string, .bin, .ext, .timestamp:
            return [self]
        case .array(let values):
            var flattened: [MessagePackValue] = []
            flattened.reserveCapacity(values.count)
            for v in values {
                flattened.append(contentsOf: v.flattened())
            }
            return flattened
        case .map(let values):
            var flattened: [MessagePackValue] = []
            flattened.reserveCapacity(values.count * 2)
            for (k, _) in values {
                flattened.append(contentsOf: k.flattened())
                flattened.append(contentsOf: k.flattened())
            }
            return flattened
        }
    }
}

extension Array {
    func flattened() -> [MessagePackValue] where Array.Element == (MessagePackValue, MessagePackValue) {
        var flattened: [MessagePackValue] = []
        flattened.reserveCapacity(self.count * 2)
        for el in self {
            flattened.append(el.0)
            flattened.append(el.1)
        }
        return flattened
    }
}

extension _MessagePackDecoder {
    final class MapUnkeyedContainer {
        var codingPath: [CodingKey]

        var nestedCodingPath: [CodingKey] {
            self.codingPath + [AnyCodingKey(intValue: self.count ?? 0)!]
        }

        var userInfo: [CodingUserInfoKey: Any]

        var count: Int? {
            self.value.count
        }

        // var value: [(MessagePackValue, MessagePackValue)]
        var value: [MessagePackValue] // flattened

        var currentIndex: Int = 0

        init(value: [(MessagePackValue, MessagePackValue)], codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.value = value.flattened()
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

extension _MessagePackDecoder.MapUnkeyedContainer: UnkeyedDecodingContainer {
    func decodeNil() throws -> Bool {
        fatalError("Not implemented: \(#function)")
    }

    func decode<T>(_ typ: T.Type) throws -> T where T: Decodable {
        defer {
            currentIndex += 1
        }
        let msgPackValue = value[currentIndex]

        return try msgPackValue.decodeInto(typ)
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("Not implemented: \(#function)")
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        fatalError("Not implemented: \(#function)")
    }

    func superDecoder() throws -> Decoder {
        fatalError("Not used.")
    }
}
