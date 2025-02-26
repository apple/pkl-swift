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

class PklSingleValueDecodingContainer: SingleValueDecodingContainer {
    private let value: MessagePackValue

    init(value: MessagePackValue, codingPath: [CodingKey]) {
        self.value = value
        self.codingPath = codingPath
    }

    var codingPath: [CodingKey]

    func decodeNil() -> Bool {
        switch self.value {
        case .nil: return true
        default: return false
        }
    }

    func decode(_: Bool.Type) throws -> Bool {
        switch self.value {
        case .bool(let value): return value
        default:
            throw DecodingError.typeMismatch(
                Bool.self,
                .init(
                    codingPath: self.codingPath,
                    debugDescription: "Expected a boolean, but got \(self.value.debugDataTypeDescription)"
                )
            )
        }
    }

    func decode(_: String.Type) throws -> String {
        switch self.value {
        case .string(let value): return value
        default:
            throw DecodingError.typeMismatch(
                String.self,
                .init(
                    codingPath: self.codingPath,
                    debugDescription: "Expected a string, but got \(self.value.debugDataTypeDescription)"
                )
            )
        }
    }

    func decode(_: Double.Type) throws -> Double {
        switch self.value {
        case .float(let value): return Double(value)
        default:
            throw DecodingError.typeMismatch(
                Double.self,
                .init(
                    codingPath: self.codingPath,
                    debugDescription: "Expected a float, but got \(self.value.debugDataTypeDescription)"
                )
            )
        }
    }

    func decode(_: Float.Type) throws -> Float {
        switch self.value {
        case .float(let value): return Float(value)
        default:
            throw DecodingError.typeMismatch(
                Float.self,
                .init(
                    codingPath: self.codingPath,
                    debugDescription: "Expected a float, but got \(self.value.debugDataTypeDescription)"
                )
            )
        }
    }

    func decode(_: Int.Type) throws -> Int {
        try self.decodeBinaryInteger()
    }

    func decode(_: Int8.Type) throws -> Int8 {
        try self.decodeBinaryInteger()
    }

    func decode(_: Int16.Type) throws -> Int16 {
        try self.decodeBinaryInteger()
    }

    func decode(_: Int32.Type) throws -> Int32 {
        try self.decodeBinaryInteger()
    }

    func decode(_: Int64.Type) throws -> Int64 {
        try self.decodeBinaryInteger()
    }

    func decode(_: UInt.Type) throws -> UInt {
        try self.decodeBinaryInteger()
    }

    func decode(_: UInt8.Type) throws -> UInt8 {
        try self.decodeBinaryInteger()
    }

    func decode(_: UInt16.Type) throws -> UInt16 {
        try self.decodeBinaryInteger()
    }

    func decode(_: UInt32.Type) throws -> UInt32 {
        try self.decodeBinaryInteger()
    }

    func decode(_: UInt64.Type) throws -> UInt64 {
        try self.decodeBinaryInteger()
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        if type == PklAny.self {
            guard let result = try _PklDecoder.decodePolymorphic(value, codingPath: codingPath) else {
                throw DecodingError.typeMismatch(T.self, .init(codingPath: self.codingPath, debugDescription: "Tried to decode but got nil"))
            }
            return result as! T
        }
        let decoder = try _PklDecoder(value: value)
        decoder.codingPath = self.codingPath
        return try T(from: decoder)
    }

    private func decodeBinaryInteger<T>() throws -> T where T: BinaryInteger {
        switch self.value {
        case .int(let value):
            guard let result = T(exactly: value) else {
                throw DecodingError.typeMismatch(
                    T.self,
                    .init(
                        codingPath: self.codingPath,
                        debugDescription: "Cannot fit \(value) into \(String(describing: T.self))"
                    )
                )
            }
            return result
        default:
            throw DecodingError.typeMismatch(
                T.self,
                .init(
                    codingPath: self.codingPath,
                    debugDescription: "Expected an int, but got \(self.value.debugDataTypeDescription)"
                )
            )
        }
    }
}
