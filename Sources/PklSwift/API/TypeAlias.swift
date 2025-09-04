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

/// TypeAlias is the Swift representation of Pkl's `pkl.base#TypeAlias`.
public struct TypeAlias: Hashable {
    /// The URI of the module containing this typealias.
    /// Will be an empty string for values encoded by Pkl versions older than 0.30.
    public let moduleUri: String

    /// The qualified name of this typealias.
    /// Will be an empty string for values encoded by Pkl versions older than 0.30.
    public let qualifiedName: String
}

extension TypeAlias: PklSerializableType, Sendable {
    public static let messageTag: PklValueType = .typealias

    public static func decode(_ fields: [MessagePackValue], codingPath: [any CodingKey]) throws -> TypeAlias {
        if fields.count > 1 { // pkl 0.30+ includes the qualified name and module uri
            try checkFieldCount(fields, codingPath: codingPath, min: 3)
            return try TypeAlias(
                moduleUri: fields[1].decode(String.self),
                qualifiedName: fields[2].decode(String.self)
            )
        }

        try checkFieldCount(fields, codingPath: codingPath, min: 1)
        return TypeAlias(moduleUri: "", qualifiedName: "")
    }
}
