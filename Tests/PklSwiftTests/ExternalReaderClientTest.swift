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

import SemanticVersion
import XCTest

@testable import PklSwift

class ExternalReaderClientTest: XCTestCase {
    func testE2E() async throws {
        let version = try await SemanticVersion(EvaluatorManager().getVersion())!
        guard version >= pklVersion0_27 else {
            throw XCTSkip("External readers require Pkl 0.27 or later.")
        }

        let tempDir = try tempDir()
        let testFile = tempDir.appendingPathComponent("test.pkl")
        try #"""
        import "pkl:test"

        fib5 = read("fib:5").text.toInt()
        fib10 = read("fib:10").text.toInt()
        fib20 = read("fib:20").text.toInt()

        fibErrA = test.catch(() -> read("fib:%20"))
        fibErrB = test.catch(() -> read("fib:abc"))
        fibErrC = test.catch(() -> read("fib:-10"))
        """#.write(to: testFile, atomically: true, encoding: .utf8)

        let expectedResult = """
        fib5 = 5
        fib10 = 55
        fib20 = 6765
        fibErrA = "I/O error reading resource `fib:%20`. IOException: PklError(message: \\"input uri must be in format fib:<positive integer>\\")"
        fibErrB = "I/O error reading resource `fib:abc`. IOException: PklError(message: \\"input uri must be in format fib:<positive integer>\\")"
        fibErrC = "I/O error reading resource `fib:-10`. IOException: PklError(message: \\"input uri must be in format fib:<positive integer>\\")"
        """

        let opts = EvaluatorOptions(
            allowedModules: ["file:", "repl:text"],
            allowedResources: ["fib:", "prop:"],
            externalResourceReaders: [
                "fib": ExternalReader(executable: "./.build/debug/test-external-reader"),
            ]
        )

        try await withEvaluator(options: opts) { evaluator in
            let result = try await evaluator.evaluateOutputText(source: .url(testFile))
            XCTAssertEqual(result.trimmingCharacters(in: .whitespacesAndNewlines), expectedResult.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}
