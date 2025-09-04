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

public struct PklTypeAlias: Hashable {}

extension PklTypeAlias: PklSerializableType {
    public static let messageTag: PklValueType = .typealias

    public init(from decoder: Decoder) throws {
        // guard let decoder = decoder as? _PklDecoder else {
        //     fatalError("\(Self.self) can only be decoded using \(_PklDecoder.self), but was: \(decoder)")
        // }
        // noop currently
    }
}
