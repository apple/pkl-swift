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

// Must be marked @unchecked Sendable because A or B can be AnyHashable
public struct Pair<A: Hashable, B: Hashable>: Hashable, @unchecked Sendable {
    /// The value of the Pair's first element.
    public let first: A

    /// The value of the Pair's second element.
    public let second: B

    public init(_ first: A, _ second: B) {
        self.first = first
        self.second = second
    }

    public var tupleValue: (A, B) { (self.first, self.second) }
}

extension Pair {
    // this can't be a let because Pair is generic
    public static var messageTag: PklValueType { .pair }
}

extension Pair: PklSerializableType {
    public static func decode(_ fields: [MessagePackValue], codingPath: [any CodingKey]) throws -> Self {
        try checkFieldCount(fields, codingPath: codingPath, min: 3)
        let first: A = try Self.decodeElement(fields[1], codingPath: codingPath)
        let second: B = try Self.decodeElement(fields[2], codingPath: codingPath)
        return Self(first, second)
    }

    private static func decodeElement<T: Decodable>(_ value: MessagePackValue, codingPath: [any CodingKey]) throws -> T {
        try value.decode(T.self)
    }

    private static func decodeElement<T: Hashable>(_ value: MessagePackValue, codingPath: [any CodingKey]) throws -> T {
        try (_PklDecoder.decodePolymorphic(value, codingPath: codingPath))?.value as! T
    }
}
