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

public struct PklRegex: Sendable {
    private let pattern: String

    public var regex: Regex<AnyRegexOutput> { try! Regex(self.pattern) }

    public init(_ pattern: String) throws {
        self.pattern = pattern
        // check that this pattern is valid but don't store the regex
        _ = try Regex(pattern)
    }
}

extension PklRegex: Hashable {
    public func hash(into hasher: inout Hasher) {
        self.pattern.hash(into: &hasher)
    }

    public static func == (lhs: PklRegex, rhs: PklRegex) -> Bool {
        lhs.pattern == rhs.pattern
    }
}

extension PklRegex: PklSerializableType {
    public static var messageTag: PklValueType { .regex }

    public static func decode(_ fields: [MessagePackValue], codingPath: [any CodingKey]) throws -> Self {
        try checkFieldCount(fields, codingPath: codingPath, min: 2)
        guard case .string(let pattern) = fields[1] else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected field 0 to be a string but got \(fields[0].debugDataTypeDescription)"
                ))
        }
        return try Self(pattern)
    }
}
