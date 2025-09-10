//===----------------------------------------------------------------------===//
// Copyright © 2025 Apple Inc. and the Pkl project authors. All rights reserved.
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

public struct IntSeq: Decodable, Sendable {
    public let start: Int
    public let end: Int
    public let step: Int

    public let intSeq: StrideThrough<Int>

    public init(start: Int, end: Int, step: Int = 1) {
        self.start = start
        self.end = end
        self.step = step
        self.intSeq = stride(from: start, through: end, by: step)
    }
}

extension IntSeq: Hashable {
    public func hash(into hasher: inout Hasher) {
        self.start.hash(into: &hasher)
        self.end.hash(into: &hasher)
        self.step.hash(into: &hasher)
    }

    public static func == (lhs: IntSeq, rhs: IntSeq) -> Bool {
        lhs.start == rhs.start
            && lhs.end == rhs.end
            && lhs.step == rhs.step
    }
}

extension IntSeq: PklSerializableType {
    public static var messageTag: PklValueType { .intSeq }

    public static func decode(_ fields: [MessagePackValue], codingPath: [any CodingKey]) throws -> Self {
        try checkFieldCount(fields, codingPath: codingPath, min: 4)
        return try Self(
            start: self.decodeInt(fields[1], codingPath: codingPath, index: 1),
            end: self.decodeInt(fields[2], codingPath: codingPath, index: 2),
            step: self.decodeInt(fields[3], codingPath: codingPath, index: 3)
        )
    }

    private static func decodeInt(_ value: MessagePackValue, codingPath: [any CodingKey], index: Int) throws -> Int {
        guard case .int(let intValue) = value else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected field \(index) to be an integer but got \(value.debugDataTypeDescription)"
                ))
        }
        return Int(intValue)
    }
}
