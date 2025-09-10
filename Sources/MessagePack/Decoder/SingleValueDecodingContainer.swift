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

#if os(Linux) || os(Windows)
let NSEC_PER_SEC: UInt64 = 1_000_000_000
#endif

extension _MessagePackDecoder {
    final class SingleValueContainer: MessagePackDecodingContainer {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        let value: MessagePackValue

        init(value: MessagePackValue, codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.value = value
        }
    }
}

extension _MessagePackDecoder.SingleValueContainer: SingleValueDecodingContainer {
    func decodeNil() -> Bool {
        switch value {
        case .nil:
            return true
        default:
            return false
        }
    }

    func decode(_: Bool.Type) throws -> Bool {
        switch value {
        case .bool(let value):
            return value
        default:
            throw self.decodingError(expectedType: Bool.self, actualValue: value)
        }
    }

    func decode(_: String.Type) throws -> String {
        switch value {
        case .string(let value):
            return value
        default:
            throw self.decodingError(expectedType: String.self, actualValue: value)
        }
    }

    func decode(_: Double.Type) throws -> Double {
        switch value {
        case .float(let value):
            return Double(value)
        default:
            throw self.decodingError(expectedType: Double.self, actualValue: value)
        }
    }

    func decode(_: Float.Type) throws -> Float {
        switch value {
        case .float(let value):
            return Float(value)
        default:
            throw self.decodingError(expectedType: Float.self, actualValue: value)
        }
    }

    func decode<T>(_: T.Type) throws -> T where T: BinaryInteger & Decodable {
        switch value {
        case .int(let value):
            guard let value = value as? T else {
                return T(value)
            }
            return value
        default:
            throw self.decodingError(expectedType: T.self, actualValue: value)
        }
    }

    private func decode(_: Date.Type) throws -> Date {
        switch value {
        case .timestamp(let value):
            return value
        default:
            throw self.decodingError(expectedType: Date.self, actualValue: value)
        }
    }

    private func decode(_: Data.Type) throws -> Data {
        switch value {
        case .bin(let value):
            return Data(value)
        default:
            throw self.decodingError(expectedType: Data.self, actualValue: value)
        }
    }

    private func decode(_: [UInt8].Type) throws -> [UInt8] {
        // accept either msgpack binary or array
        switch value {
        case .bin(let value):
            return value
        case .array(let value):
            return try value.enumerated().map { idx, elem in
                if case .int(let num) = elem {
                    return UInt8(num)
                } else {
                    var codingPath = self.codingPath
                    codingPath.append(AnyCodingKey(idx: idx))
                    throw self.decodingError(codingPath: codingPath, expectedType: UInt8.self, actualValue: elem)
                }
            }
        default:
            throw self.decodingError(expectedType: [UInt8].self, actualValue: value)
        }
    }

    private func decode(_: URL.Type) throws -> URL {
        switch value {
        case .string(let value):
            if let url = URL(string: value) {
                return url
            }
            throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "Could not parse \(value) into URL"))
        default:
            throw self.decodingError(expectedType: String.self, actualValue: value)
        }
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        switch type {
        case is Data.Type:
            return try self.decode(Data.self) as! T
        case is Date.Type:
            return try self.decode(Date.self) as! T
        case is [UInt8].Type:
            return try self.decode([UInt8].self) as! T
        case is URL.Type:
            return try self.decode(URL.self) as! T
        default:
            let decoder = _MessagePackDecoder(value: value)
            let value = try T(from: decoder)
            return value
        }
    }

    func decodingError(expectedType: Any.Type, actualValue: MessagePackValue)
        -> DecodingError {
        self.decodingError(codingPath: codingPath, expectedType: expectedType, actualValue: actualValue)
    }

    func decodingError(codingPath: [CodingKey], expectedType: Any.Type, actualValue: MessagePackValue)
        -> DecodingError {
        let context = DecodingError.Context(
            codingPath: codingPath, debugDescription: "Invalid format: \(value.debugDataTypeDescription)"
        )
        return DecodingError.typeMismatch(expectedType, context)
    }
}
