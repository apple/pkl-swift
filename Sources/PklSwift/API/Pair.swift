// ===----------------------------------------------------------------------===//
// Copyright © 2024 Apple Inc. and the Pkl project authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//	https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ===----------------------------------------------------------------------===//

import Foundation

/// Pair is the Swift representation of Pkl's `pkl.Pair`.
public struct Pair<A, B>: Hashable where A: Hashable, B: Hashable {
    public init(_ first: A, _ second: B) {
        self.first = first
        self.second = second
    }

    /// The value of the first component of this ``Pair``.
    let first: A

    /// The value of the second component of this ``Pair``.
    let second: B
}

extension Pair: CustomStringConvertible where A: CustomStringConvertible, B: CustomStringConvertible {
    public var description: String {
        "Pair(\(self.first.description), \(self.second.description))"
    }
}

extension Pair: Decodable where A: Decodable, B: Decodable {
    public init(from decoder: Decoder) throws {
        var partsDecoder = try decoder.unkeyedContainer()
        self.first = try partsDecoder.decode(A.self)
        self.second = try partsDecoder.decode(B.self)
    }
}
