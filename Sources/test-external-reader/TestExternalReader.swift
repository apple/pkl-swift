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
import PklSwift

@main
struct TestExternalReader {
    static func main() async throws {
        let client = ExternalReaderClient(
            options: ExternalReaderClientOptions(
                resourceReaders: [FibReader()]
            ))
        try await client.run()
    }
}

struct FibReader: ResourceReader {
    var scheme: String { "fib" }
    var isGlobbable: Bool { false }
    var hasHierarchicalUris: Bool { false }
    func listElements(uri: URL) async throws -> [PathElement] { throw PklError("not implemented") }
    func read(url: URL) async throws -> [UInt8] {
        let key = url.absoluteString.dropFirst(scheme.count + 1)
        guard let n = Int(key), n > 0 else {
            throw PklError("input uri must be in format fib:<positive integer>")
        }
        return Array(String(fibonacci(n: n)).utf8)
    }
}

func fibonacci(n: Int) -> Int {
    var (a, b) = (0, 1)
    for _ in 0..<n {
        (a, b) = (b, a + b)
    }
    return a
}
