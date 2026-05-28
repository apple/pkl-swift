//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the Pkl project authors. All rights reserved.
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

import PklMessagePack

/// Reference is the Swift representation of Pkl's `pkl.ref#Reference`.
public struct Reference<D: Hashable>: Hashable, @unchecked Sendable {
    /// Reference domain.
    public let domain: D

    /// Reference data.
    public let data: AnyHashable?

    /// Reference access path.
    public let path: [ReferenceAccess]

    public static var messageTag: PklValueType { .reference }
}

extension Reference: PklSerializableType {
    public static func decode(_ fields: [MessagePackValue], codingPath: [any CodingKey]) throws -> Reference {
        try checkFieldCount(fields, codingPath: codingPath, min: 3)
        let pathCodingPath = codingPath + [PklCodingKey(intValue: 3)!]
        guard case .array(let path) = fields[3] else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: pathCodingPath,
                    debugDescription: "Expected array type but got \(fields[3].debugDescription)"
                ))
        }
        return try Reference(
            domain: _PklDecoder.decodePolymorphic(
                fields[1],
                codingPath: codingPath + [PklCodingKey(intValue: 1)!]
            )?.value as! D,
            data: _PklDecoder.decodePolymorphic(
                fields[2],
                codingPath: codingPath + [PklCodingKey(intValue: 2)!]
            )?.value,
            path: path.enumerated().map {
                try ReferenceAccess(from: _PklDecoder(
                    value: $0.1,
                    codingPath: pathCodingPath + [PklCodingKey(intValue: $0.0)!]
                ))
            },
        )
    }
}

/// ReferenceAccess is the Swift representation of Pkl's `pkl.ref#Access`.
public enum ReferenceAccess: PklRegisteredType, Decodable, Hashable, @unchecked Sendable {
    public static let registeredIdentifier: String = "pkl.ref#Access"

    case property(String)
    case subscriptKey(AnyHashable?)

    public init(from decoder: any Decoder) throws {
        let dec = try decoder.container(keyedBy: PklCodingKey.self)
        if let property = try dec.decode(String?.self, forKey: PklCodingKey(string: "property")) {
            self = .property(property)
        } else {
            self = try .subscriptKey(dec.decode(PklAny.self, forKey: PklCodingKey(string: "key")).value)
        }
    }
}
