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

import Foundation
import PklMessagePack

let pklNetUrlIdentifier = "pkl.net#Url"

extension _PklDecoder {
    /// Decodes a `URL` from either a `pkl.net#Url` or a `pkl.base#String`.
    static func decodeURL(_ value: MessagePackValue, codingPath: [CodingKey]) throws -> URL {
        switch value {
        case .string(let str):
            return try self.parseURL(str, from: "pkl.base#String", codingPath: codingPath)
        case .array(let arr) where arr.count > 1 && (try? arr[0].decode(PklValueType.self)) == .object:
            let container = try PklTypedDecodingContainer<PklCodingKey>(value: arr, codingPath: codingPath)
            guard container.className == pklNetUrlIdentifier else {
                throw DecodingError.typeMismatch(
                    URL.self,
                    .init(
                        codingPath: codingPath,
                        debugDescription: "Cannot decode `\(container.className)` into `URL`"
                    )
                )
            }
            let stringValue = try container.decode(String.self, forKey: PklCodingKey(string: "stringValue"))
            return try self.parseURL(stringValue, from: pklNetUrlIdentifier, codingPath: codingPath)
        default:
            throw DecodingError.typeMismatch(
                URL.self,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected `pkl.net#Url` or `pkl.base#String`, but got \(value.debugDataTypeDescription)"
                )
            )
        }
    }

    private static func parseURL(_ str: String, from pklType: String, codingPath: [CodingKey]) throws -> URL {
        guard let url = URL(string: str) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Failed to convert `\(pklType)` `\(str)` to `URL`"
                ))
        }
        return url
    }
}
