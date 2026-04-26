//===----------------------------------------------------------------------===//
// Copyright © 2024-2026 Apple Inc. and the Pkl project authors. All rights reserved.
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
import XCTest
import PklSwift
@testable import PklSwiftContrib

#if os(macOS) || os(Linux) || os(Windows)
final class VirtualFileReaderTests: XCTestCase {
    var manager: EvaluatorManager!

    override func setUp() {
        self.manager = EvaluatorManager()
    }

    override func tearDown() async throws {
        await self.manager.close()
    }

    // MARK: - Initializer validation

    /// The initializer throws when a key does not start with `/`.
    func testInitThrowsOnInvalidPath() {
        XCTAssertThrowsError(try VirtualFileReader("mem", [
            "config.pkl": "x = 1",
        ])) { error in
            XCTAssertTrue(
                "\(error)".contains("config.pkl"),
                "Error should mention the invalid path; got: \(error)"
            )
        }
    }

    // MARK: - Basic evaluation

    /// A single virtual file is read and evaluated successfully.
    func testBasicRead() async throws {
        let reader = try VirtualFileReader("mem", [
            "/config.pkl": "host = \"localhost\"\nport = 8080",
        ])
        let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        let output = try await evaluator.evaluateOutputText(source: .uri("mem:/config.pkl")!)
        XCTAssertEqual(output, "host = \"localhost\"\nport = 8080\n")
        try await evaluator.close()
    }

    /// A module that amends another virtual file resolves the base through the same reader.
    func testMultiFileAmends() async throws {
        let reader = try VirtualFileReader("mem", [
            "/base.pkl":   "abstract module Base\nhost: String",
            "/config.pkl": #"amends "mem:/base.pkl"\nhost = "localhost""#,
        ])
        let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        let output = try await evaluator.evaluateOutputText(source: .uri("mem:/config.pkl")!)
        XCTAssertEqual(output, "host = \"localhost\"\n")
        try await evaluator.close()
    }

    /// `import*(...)` glob resolves to all matching virtual files, sorted deterministically.
    func testGlobImport() async throws {
        let reader = try VirtualFileReader("mem", [
            "/birds/swallow.pkl": "name = \"Swallow\"\nnumberOfEggs = 8",
            "/birds/penguin.pkl": "name = \"Penguin\"\nnumberOfEggs = 1",
        ])
        let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        let result = try await evaluator.evaluateOutputText(source: .text("""
        result = import*("mem:/birds/*.pkl")
        """))
        XCTAssertEqual(result, """
        result {
          ["mem:/birds/penguin.pkl"] {
            name = "Penguin"
            numberOfEggs = 1
          }
          ["mem:/birds/swallow.pkl"] {
            name = "Swallow"
            numberOfEggs = 8
          }
        }

        """)
        try await evaluator.close()
    }

    /// Requesting a path not present in the dictionary throws `VirtualFileReaderError.fileNotFound`.
    func testFileNotFound() async throws {
        let reader = try VirtualFileReader("mem", [:])
        let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        do {
            _ = try await evaluator.evaluateOutputText(source: .uri("mem:/missing.pkl")!)
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertTrue(
                "\(error)".contains("/missing.pkl"),
                "Error message should mention the missing path; got: \(error)"
            )
        }
        try await evaluator.close()
    }

    /// A reader initialised with a non-default scheme is registered and evaluated correctly.
    func testCustomScheme() async throws {
        let reader = try VirtualFileReader("virtual", [
            "/config.pkl": "answer = 42",
        ])
        let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        let output = try await evaluator.evaluateOutputText(source: .uri("virtual:/config.pkl")!)
        XCTAssertEqual(output, "answer = 42\n")
        try await evaluator.close()
    }

    /// `listElements` returns only *direct* children of the requested URI,
    /// not grandchildren, so that glob patterns resolve one level at a time.
    func testListElementsDirectChildrenOnly() async throws {
        let reader = try VirtualFileReader("mem", [
            "/a/b/deep.pkl": "x = 1",
            "/a/shallow.pkl": "y = 2",
            "/other.pkl": "z = 3",
        ])
        // List the direct children of "mem:/a/"
        let base = URL(string: "mem:/a/")!
        let elements = try await reader.listElements(uri: base)

        // Expect exactly two children: "b" (directory) and "shallow.pkl" (file)
        XCTAssertEqual(elements.count, 2)
        let names = elements.map(\.name)
        XCTAssertTrue(names.contains("b"), "Expected directory 'b'; got \(names)")
        XCTAssertTrue(names.contains("shallow.pkl"), "Expected file 'shallow.pkl'; got \(names)")

        let bEntry = elements.first { $0.name == "b" }!
        XCTAssertTrue(bEntry.isDirectory, "'b' should be reported as a directory")

        let shallowEntry = elements.first { $0.name == "shallow.pkl" }!
        XCTAssertFalse(shallowEntry.isDirectory, "'shallow.pkl' should not be reported as a directory")
    }
}
#endif
