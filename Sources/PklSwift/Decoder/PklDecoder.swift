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
import MessagePack

public enum PklValueType: UInt8, Decodable, Sendable {
    case object = 0x01
    case map = 0x02
    case mapping = 0x03
    case list = 0x04
    case listing = 0x05
    case set = 0x06
    case duration = 0x07
    case dataSize = 0x08
    case pair = 0x09
    case intSeq = 0x0A
    case regex = 0x0B
    case `class` = 0x0C
    case `typealias` = 0x0D
    case function = 0x0E
    case bytes = 0x0F
    case objectMemberProperty = 0x10
    case objectMemberEntry = 0x11
    case objectMemberElement = 0x12
}

public protocol PklSerializableType: Decodable {
    static var messageTag: PklValueType { get }

    static func decode(_ fields: [MessagePackValue], codingPath: [any CodingKey]) throws -> Self
}

extension PklSerializableType {
    static func checkFieldCount(_ fields: [MessagePackValue], codingPath: [any CodingKey], min: Int) throws {
        guard fields.count >= min else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected at least \(min) fields but got \(fields.count)"
                ))
        }
    }
}

public protocol PklSerializableValueUnitType: PklSerializableType {
    associatedtype ValueType: Decodable = Float64
    associatedtype UnitType: Decodable

    init(_: ValueType, unit: UnitType)
}

extension Decodable where Self: PklSerializableType {
    public init(from decoder: Decoder) throws {
        guard let decoder = decoder as? _PklDecoder else {
            fatalError("\(Self.self) can only be decoded using \(_PklDecoder.self), but was: \(decoder)")
        }
        let codingPath = decoder.codingPath
        guard case .array(let arr) = decoder.value else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected array but got \(decoder.value.debugDataTypeDescription)"
                ))
        }
        let code = try arr[0].decode(PklValueType.self)
        guard arr.count > 0 else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected non-empty array"
                ))
        }
        guard Self.messageTag == code else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: codingPath, debugDescription: "Cannot decode \(code) into \(Self.self)"))
        }
        self = try Self.decode(arr, codingPath: codingPath)
    }
}

extension Decodable where Self: PklSerializableValueUnitType {
    public static func decode(_ fields: [MessagePackValue], codingPath: [any CodingKey]) throws -> Self {
        try checkFieldCount(fields, codingPath: codingPath, min: 3)
        let value = try fields[1].decode(Self.ValueType.self)
        let unit = try fields[2].decode(Self.UnitType.self)
        return Self(value, unit: unit)
    }
}

extension PklSerializableValueUnitType {
    static func decodeValueUnitType(
        from value: MessagePackValue,
        at codingPath: [CodingKey]
    ) throws -> Self {
        guard case .array(let arr) = value else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected array but got \(value.debugDataTypeDescription)"
                ))
        }
        let code = try arr[0].decode(PklValueType.self)
        guard Self.messageTag == code else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: codingPath, debugDescription: "Cannot decode \(code) into \(Self.self)"))
        }

        let value = try arr[1].decode(Self.ValueType.self)
        let unit = try arr[2].decode(Self.UnitType.self)
        return Self(value, unit: unit)
    }
}

public enum PklDecoder {}

extension PklDecoder {
    public static func decode<T>(_ type: T.Type, from bytes: [UInt8]) throws -> T where T: Decodable {
        let reader = BufferReader(bytes)
        let value = try MessagePackDecoder(reader: reader).decodeGeneric()
        return try T(from: _PklDecoder(value: value))
    }
}

final class _PklDecoder: Decoder {
    var codingPath: [CodingKey] = []

    // not used
    var userInfo: [CodingUserInfoKey: Any] {
        get {
            [:]
        }
        set {
            // ignore, not used
        }
    }

    let value: MessagePackValue

    init(value: MessagePackValue, codingPath: [CodingKey] = []) throws {
        self.value = value
        self.codingPath = codingPath
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
        where Key: CodingKey {
        try _PklDecoder.getNestedKeyedContainer(keyedBy: type, value: self.value, codingPath: self.codingPath)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        switch self.value {
        case .array(let value):
            return try PklUnkeyedDecodingContainer(value: value, codingPath: self.codingPath)
        default:
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: self.codingPath,
                    debugDescription: "Expected an array type, but got \(self.value.debugDataTypeDescription)"
                ))
        }
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        PklSingleValueDecodingContainer(value: self.value, codingPath: self.codingPath)
    }
}

extension _PklDecoder {
    static func getNestedKeyedContainer<NestedKey>(
        keyedBy type: NestedKey.Type, value: MessagePackValue, codingPath: [CodingKey]
    ) throws -> KeyedDecodingContainer<NestedKey> {
        switch value {
        case .array(let value):
            if value.count < 2 {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: codingPath,
                        debugDescription: "Expected array with at least 2 items, type but got \(value.count)"
                    ))
            }
            let type = try value[0].decode(PklValueType.self)
            switch type {
            case .map, .mapping:
                let container = try PklMapDecodingContainer<NestedKey>(value: value, codingPath: codingPath)
                return KeyedDecodingContainer(container)
            case .object:
                let container = try PklTypedDecodingContainer<NestedKey>(
                    value: value, codingPath: codingPath
                )
                return KeyedDecodingContainer(container)
            default:
                throw DecodingError.typeMismatch(
                    [Any].self,
                    .init(
                        codingPath: codingPath,
                        debugDescription: "Expected some sort of map type but got \(type)"
                    )
                )
            }
        default:
            throw DecodingError.typeMismatch(
                [Any].self,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected an array type but got \(value.debugDataTypeDescription)"
                )
            )
        }
    }

    static func decodePolymorphic(_ propertyValue: MessagePackValue, codingPath: [CodingKey]) throws -> PklAny? {
        switch propertyValue {
        case .nil:
            return PklAny(value: nil)
        case .array(let value):
            if value.count < 2 {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: codingPath,
                        debugDescription: "Expected array with at least 2 items, type but got \(value.count)"
                    ))
            }
            let type = try value[0].decode(PklValueType.self)
            switch type {
            case .object:
                let tag = try value[1].decode(String.self)
                guard TypeRegistry.get().has(identifier: tag) else {
                    return nil
                }
                let val = try TypeRegistry.get().decode(value: propertyValue, identifiedBy: tag, as: AnyHashable?.self)
                return PklAny(value: val)
            case .list, .listing, .set:
                guard case .array(let pklArray) = value[1] else {
                    throw DecodingError.dataCorrupted(
                        .init(
                            codingPath: codingPath,
                            debugDescription: "Expected array type but got \(value[1].debugDescription)"
                        ))
                }
                var arr: [AnyHashable?] = []
                arr.reserveCapacity(pklArray.count)
                for v in pklArray {
                    try arr.append(self.decodePolymorphic(v, codingPath: codingPath)?.value)
                }
                if case .set = type {
                    return PklAny(value: Set(arr))
                } else {
                    return PklAny(value: arr)
                }
            case .map, .mapping:
                guard case .map(let pklMap) = value[1] else {
                    throw DecodingError.dataCorrupted(
                        .init(
                            codingPath: codingPath,
                            debugDescription: "Expected map type but got \(value[1].debugDescription)"
                        ))
                }
                var map: [AnyHashable?: AnyHashable?] = [:]
                for (k, v) in pklMap {
                    let key = try decodePolymorphic(k, codingPath: codingPath)?.value
                    let val = try decodePolymorphic(v, codingPath: codingPath)?.value
                    map[key] = val
                }
                return PklAny(value: map)
            case .duration:
                let decoder = try _PklDecoder(value: propertyValue)
                return try PklAny(value: Duration(from: decoder))
            case .dataSize:
                let decoder = try _PklDecoder(value: propertyValue)
                return try PklAny(value: DataSize(from: decoder))
            case .class:
                let decoder = try _PklDecoder(value: propertyValue)
                return try PklAny(value: PklClass(from: decoder))
            case .typealias:
                let decoder = try _PklDecoder(value: propertyValue)
                return try PklAny(value: PklTypeAlias(from: decoder))
            case .bytes:
                guard case .bin(let bytes) = value[1] else {
                    throw DecodingError.dataCorrupted(
                        .init(
                            codingPath: codingPath,
                            debugDescription: "Expected binary type but got \(value[1].debugDescription)"
                        ))
                }
                return PklAny(value: bytes)
            default:
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: codingPath,
                        debugDescription: "Unexpected type \(value[0].debugDescription)"
                    ))
            }
        case .bool(let b):
            return PklAny(value: b)
        case .string(let str):
            return PklAny(value: str)
        case .int(let i):
            return PklAny(value: i as? AnyHashable)
        case .float(let f):
            return PklAny(value: f as? AnyHashable)
        default:
            throw DecodingError.typeMismatch(
                [Any].self,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Unexpected type for polymorphic decoding \(propertyValue.debugDataTypeDescription)"
                )
            )
        }
    }
}

public struct _PklKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    static let `super` = _PklKey(stringValue: "super")!
}

/// Represents any possible Pkl value
public struct PklAny: Decodable, Hashable {
    public let value: AnyHashable?

    public init(value: AnyHashable?) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        // this should never happen because other decoders should handle the decoding
        throw DecodingError.dataCorrupted(
            .init(
                codingPath: decoder.codingPath,
                debugDescription: "Could not decode polymorphic type"
            ))
    }
}
