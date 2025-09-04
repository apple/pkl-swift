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

extension StrideThrough: @retroactive Hashable, @retroactive Equatable where Element: BinaryInteger, Element.Stride: BinaryInteger {
    public func hash(into hasher: inout Hasher) {
        forEach { $0.hash(into: &hasher) }
    }

    public static func == (lhs: StrideThrough, rhs: StrideThrough) -> Bool {
        lhs.elementsEqual(rhs)
    }
}

extension StrideThrough: @retroactive Decodable, PklSerializableType where Element: BinaryInteger, Element.Stride: BinaryInteger {
    public static var messageTag: PklValueType { .intSeq }

    private static func decodeInt<T: BinaryInteger>(_ value: MessagePackValue, codingPath: [any CodingKey], index: Int) throws -> T {
        guard case .int(let intValue) = value else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected field \(index) to be an integer but got \(value.debugDataTypeDescription)"
                ))
        }
        return T(intValue)
    }

    public static func decode(_ fields: [MessagePackValue], codingPath: [any CodingKey]) throws -> Self {
        try checkFieldCount(fields, codingPath: codingPath, min: 4)
        let start: Element = try decodeInt(fields[1], codingPath: codingPath, index: 0)
        let end: Element = try decodeInt(fields[2], codingPath: codingPath, index: 1)
        let step: Element.Stride = try self.decodeInt(fields[3], codingPath: codingPath, index: 2)
        return stride(from: start, through: end, by: step)
    }
}
