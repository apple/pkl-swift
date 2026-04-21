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
@testable import MessagePack
@testable import PklSwift
import SemanticVersion
import XCTest

class TestLogger: Logger, @unchecked Sendable {
    var logLines: [String] = []

    func trace(message: String, frameUri: String) {
        self.logLines.append(formatLogMessage(level: "TRACE", message: message, frameUri: frameUri))
    }

    func warn(message: String, frameUri: String) {
        self.logLines.append(formatLogMessage(level: "WARN", message: message, frameUri: frameUri))
    }
}

struct VirtualModuleReader: ModuleReader {
    func read(url: URL) async throws -> String {
        try await self.read(url)
    }

    func listElements(uri: URL) async throws -> [PathElement] {
        try await self.listElements(uri)
    }

    var read: @Sendable (URL) async throws -> String

    var listElements: @Sendable (URL) async throws -> [PathElement]

    var scheme: String

    var isGlobbable: Bool

    var hasHierarchicalUris: Bool

    var isLocal: Bool
}

struct VirtualResourceReader: ResourceReader {
    var scheme: String

    var isGlobbable: Bool

    var hasHierarchicalUris: Bool

    var read: @Sendable (URL) async throws -> [UInt8]

    var listElements: @Sendable (URL) async throws -> [PathElement]

    func read(url: URL) async throws -> [UInt8] {
        try await self.read(url)
    }

    func listElements(uri: URL) async throws -> [PathElement] {
        try await self.listElements(uri)
    }
}

#if os(macOS) || os(Linux) || os(Windows)
final class PklSwiftTests: XCTestCase {
    var manager: EvaluatorManager!

    override func setUp() {
        self.manager = EvaluatorManager()
    }

    override func tearDown() async throws {
        await self.manager.close()
    }

    func testEvaluateOutputText() async throws {
        let evaluator = try await manager.newEvaluator(options: EvaluatorOptions.preconfigured)
        let output = try await evaluator.evaluateOutputText(source: .text("foo = 1"))
        XCTAssertEqual(output, "foo = 1\n")
        try await evaluator.close()
    }

    func testEvaluateOutputBytes() async throws {
        let version = try await SemanticVersion(EvaluatorManager().getVersion())!
        if version < pklVersion0_29 {
            throw XCTSkip("Bytes() is not available")
        }
        let evaluator = try await manager.newEvaluator(options: EvaluatorOptions.preconfigured)
        let output = try await evaluator.evaluateOutputBytes(source: .text("output { bytes = Bytes(1, 2, 3, 255) }"))
        XCTAssertEqual(output, [1, 2, 3, 255])
        try await evaluator.close()
    }

    func testEvaluateOutputFilesBytes() async throws {
        let version = try await SemanticVersion(EvaluatorManager().getVersion())!
        if version < pklVersion0_29 {
            throw XCTSkip("Bytes() is not available")
        }
        let evaluator = try await manager.newEvaluator(options: EvaluatorOptions.preconfigured)
        let output = try await evaluator.evaluateOutputFilesBytes(
            source: .text(
                """
                output {
                    files {
                        ["foo.bin"] {
                            bytes = Bytes(1, 2, 3, 255)
                        }
                        ["bar.bin"] {
                            bytes = Bytes()
                        }
                    }
                }
                """
            )
        )
        XCTAssertEqual(output, [
            "foo.bin": [1, 2, 3, 255],
            "bar.bin": [],
        ])
        try await evaluator.close()
    }

    func testEvaluateOutputFiles() async throws {
        let evaluator = try await manager.newEvaluator(options: EvaluatorOptions.preconfigured)
        let output = try await evaluator.evaluateOutputFiles(
            source: .text(
                """
                output {
                    files {
                        ["foo"] { text = "foo" }
                        ["bar"] { text = "bar" }
                    }
                }
                """
            )
        )
        XCTAssertEqual(output, [
            "foo": "foo",
            "bar": "bar",
        ])
        try await evaluator.close()
    }

    func testEvaluateOutputFilesNull() async throws {
        let evaluator = try await manager.newEvaluator(options: EvaluatorOptions.preconfigured)
        let output = try await evaluator.evaluateOutputFiles(
            source: .text(
                """
                output {
                    files = null
                }
                """
            )
        )
        XCTAssertEqual(output, [:])
        try await evaluator.close()
    }

    func testVersionCoverage() async throws {
        let output = try await SemanticVersion(EvaluatorManager().getVersion())!
        XCTAssert(supportedPklVersions.contains { $0.major == output.major && $0.minor == output.minor })
    }

    func testCustomProxyOptions() async throws {
        let version = try await SemanticVersion(EvaluatorManager().getVersion())!
        let expected = version < pklVersion0_26
            ? "http options are not supported on Pkl versions lower than 0.26"
            : "ConnectException: Error connecting to host `example.com`"
        var options = EvaluatorOptions.preconfigured
        options.http = .init(
            caCertificates: nil,
            proxy: .init(
                address: "http://localhost:1",
                noProxy: ["myhost.com:1337", "myotherhost.org:42"]
            )
        )
        do {
            let evaluator = try await manager.newEvaluator(options: options)
            let _ = try await evaluator.evaluateOutputText(source: .uri("https://example.com")!)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssert("\(error)".contains(expected))
        }
    }

    func testCustomModuleReader() async throws {
        let reader = VirtualModuleReader(
            read: { _ in
                """
                name = "Swallow"
                numberOfEggs = 8
                """
            },
            listElements: { _ in [] },
            scheme: "birds",
            isGlobbable: true,
            hasHierarchicalUris: true,
            isLocal: true
        )
        let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        let output = try await evaluator.evaluateOutputText(source: .text("""
        import "birds:/catalog/swallow.pkl"

        result = swallow
        """))
        XCTAssertEqual(output, """
        result {
          name = "Swallow"
          numberOfEggs = 8
        }

        """)
    }

    func testGlobCustomModuleReader() async throws {
        let reader = VirtualModuleReader(
            read: { url in
                switch url {
                case URL(string: "birds:/swallow.pkl"):
                    return
                        """
                        name = "Swallow"
                        numberOfEggs = 8
                        """
                case URL(string: "birds:/penguin.pkl"):
                    return
                        """
                        name = "Penguin"
                        numberOfEggs = 1
                        """
                default:
                    throw PklError("File not found")
                }
            },
            listElements: { _ in [.init(name: "swallow.pkl", isDirectory: false), .init(name: "penguin.pkl", isDirectory: false)] },
            scheme: "birds",
            isGlobbable: true,
            hasHierarchicalUris: true,
            isLocal: true
        )
        let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        let result = try await evaluator.evaluateOutputText(source: .text("""
        result = import*("birds:/*.pkl")
        """))
        XCTAssertEqual(result, """
        result {
          ["birds:/penguin.pkl"] {
            name = "Penguin"
            numberOfEggs = 1
          }
          ["birds:/swallow.pkl"] {
            name = "Swallow"
            numberOfEggs = 8
          }
        }

        """)
    }

    func testTripleDotImports() async throws {
        let reader = VirtualModuleReader(
            read: { url in
                switch url.path {
                case "/dir1/dir2/dir3/Bird.pkl":
                    return #"amends "...""#
                case "/Bird.pkl":
                    return #"name = "Birdy""#
                default:
                    throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadNoSuchFileError)
                }
            },
            listElements: { url in
                switch url.path {
                case "/dir1/dir2":
                    return [.init(name: "dir3", isDirectory: true)]
                case "/dir1":
                    return [.init(name: "dir2", isDirectory: true)]
                case "/":
                    return [.init(name: "Bird.pkl", isDirectory: false), .init(name: "dir1", isDirectory: true)]
                default:
                    throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError)
                }
            },
            scheme: "birds",
            isGlobbable: true,
            hasHierarchicalUris: true,
            isLocal: true
        )
        let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        let result = try await evaluator.evaluateOutputText(source: ModuleSource.uri("birds:/dir1/dir2/dir3/Bird.pkl")!)
        XCTAssertEqual(result, #"name = "Birdy"\#n"#)
    }

    func testConcurrenctEvaluations() async throws {
        // not safe to capture `self` in a task, so making a copy
        let manager = self.manager!
        async let evalResult1 = try Task {
            let evaluator = try await manager.newEvaluator(options: .preconfigured)
            return try await evaluator.evaluateOutputText(source: .text("foo = 1"))
        }.result.get()

        async let evalResult2 = try Task {
            let evaluator = try await manager.newEvaluator(options: .preconfigured)
            return try await evaluator.evaluateOutputText(source: .text("foo = 2"))
        }.result.get()

        async let evalResult3 = try Task {
            let evaluator = try await manager.newEvaluator(options: .preconfigured)
            return try await evaluator.evaluateOutputText(source: .text("foo = 3"))
        }.result.get()

        let results = try await (evalResult1, evalResult2, evalResult3)
        XCTAssertEqual(results.0, "foo = 1\n")
        XCTAssertEqual(results.1, "foo = 2\n")
        XCTAssertEqual(results.2, "foo = 3\n")
    }

    func testCustomResourceReader() async throws {
        let reader = VirtualResourceReader(
            scheme: "pizza",
            isGlobbable: false,
            hasHierarchicalUris: false,
            read: { _ in [UInt8]("yes pizza".utf8) },
            listElements: { _ in [] }
        )
        let options = EvaluatorOptions.preconfigured.withResourceReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        let output = try await evaluator.evaluateOutputText(source: .text("""
        result = read("pizza:pizza").text
        """))
        XCTAssertEqual(output, #"result = "yes pizza"\#n"#)
    }

    func testCustomResourceReaderWithSchemeContainingRegexControlCharacters() async throws {
        let reader = VirtualResourceReader(
            scheme: "foo+bar.baz",
            isGlobbable: false,
            hasHierarchicalUris: false,
            read: { _ in [UInt8]("Hello, World!".utf8) },
            listElements: { _ in [] }
        )
        let options = EvaluatorOptions.preconfigured.withResourceReader(reader)
        XCTAssert(options.allowedResources!.contains(#"\Qfoo+bar.baz:\E"#))
        let evaluator = try await manager.newEvaluator(options: options)
        let output = try await evaluator.evaluateOutputText(source: .text("""
        result = read("foo+bar.baz:quz").text
        """))
        XCTAssertEqual(output, #"result = "Hello, World!"\#n"#)
    }

    func testFailedEvaluation() async throws {
        let evaluator = try await manager.newEvaluator(options: EvaluatorOptions.preconfigured)
        do {
            _ = try await evaluator.evaluateOutputText(source: .text(#"foo = throw("uh oh")"#))
        } catch {
            XCTAssertTrue(error is PklError)
            let error = error as! PklError
            self.assertStartsWith(error.message, """
            –– Pkl Error ––
            uh oh

            1 | foo = throw("uh oh")
                      ^^^^^^^^^^^^^^
            at text#foo (repl:text)
            """)
        }
    }

    func testHttpRewrites() async throws {
        let version = try await SemanticVersion(EvaluatorManager().getVersion())!
        if version.major == 0, version.minor < 29 {
            throw XCTSkip("External readers require Pkl 0.29 or later.")
        }

        var options = EvaluatorOptions.preconfigured
        options.http = .init(
            rewrites: [
                "https://example.com/": "https://example.example/",
            ]
        )
        let evaluator = try await manager.newEvaluator(options: options)
        do {
            _ = try await evaluator.evaluateOutputText(source: .text(#"res = import("https://example.com/foo.pkl")"#))
            XCTFail("Should not reach here")
        } catch {
            XCTAssertTrue(error is PklError)
            let error = error as! PklError
            self.assertContains(error.message, "request was rewritten: https://example.com/foo.pkl -> https://example.example/foo.pkl")
        }
    }

    private func assertStartsWith(
        _ message: String,
        _ prefix: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if !message.starts(with: prefix) {
            XCTFail("Expected \(message) to start with \(prefix)", file: file, line: line)
        }
    }

    private func assertContains(
        _ message: String,
        _ value: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if !message.contains(value) {
            XCTFail("Expected \(message) to contain \(value)", file: file, line: line)
        }
    }

    func testLogger() async throws {
        var options = EvaluatorOptions.preconfigured
        let logger = TestLogger()
        options.logger = logger
        let evaluator = try await manager.newEvaluator(options: options)
        _ = try await evaluator.evaluateOutputText(source: .text(#"result = let (_ = trace("Hello there")) 1"#))
        XCTAssertEqual(logger.logLines, [#"pkl: TRACE: "Hello there" = "Hello there" (repl:text)\#n"#])
    }

    // TODO: re-enable this test when packages are available
//
//    func testWithProject() async throws {
//        let project1Dir = (try tempDir()).appendingPathComponent("project1")
//        try FileManager.default.createDirectory(at: project1Dir, withIntermediateDirectories: true)
//        try """
//        amends "pkl:Project"
//
//        dependencies {
//          ["uri"] { uri = "package://pkg.pkl-lang.org/pkl-pantry/pkl.experimental.uri@1.0.0" }
//        }
//        """.write(to: project1Dir.appendingPathComponent("PklProject"), atomically: true, encoding: .utf8)
//        try """
//        {
//          "schemaVersion": 1,
//          "resolvedDependencies": {
//            "package://pkg.pkl-lang.org/pkl-pantry/pkl.experimental.uri@1": {
//              "type": "remote",
//              "uri": "projectpackage://pkg.pkl-lang.org/pkl-pantry/pkl.experimental.uri@1.0.0",
//              "checksums": {
//                "sha256": "12a42da6a2933a802cc79cea7f5541513b5106070ca5f1236009ebefeb3d81b3"
//              }
//            }
//          }
//        }
//        """.write(to: project1Dir.appendingPathComponent("PklProject.deps.json"), atomically: true, encoding: .utf8)
//        try """
//        import "@uri/URI.pkl"
//
//        uri = URI.parse("https://www.example.com").toString()
//        """.write(to: project1Dir.appendingPathComponent("main.pkl"), atomically: true, encoding: .utf8)
//        try await withProjectEvaluator(projectDir: project1Dir.path) { evaluator in
//            let output = try await evaluator.evaluateOutputText(source: .url(project1Dir.appendingPathComponent("main.pkl")))
//            XCTAssertEqual("""
//            uri = "https://www.example.com"
//
//            """, output)
//        }
//    }

    // MARK: - InMemoryModuleReader tests

    /// A single virtual module is read and evaluated successfully.
    func testInMemoryModuleReaderBasicRead() async throws {
        let reader = InMemoryModuleReader([
            "mem:config.pkl": "host = \"localhost\"\nport = 8080",
        ])
        let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        let output = try await evaluator.evaluateOutputText(source: .uri("mem:config.pkl")!)
        XCTAssertEqual(output, "host = \"localhost\"\nport = 8080\n")
        try await evaluator.close()
    }

    /// A module that amends another virtual module resolves the base through the same reader.
    func testInMemoryModuleReaderMultiFileAmends() async throws {
        let reader = InMemoryModuleReader([
            "mem:base.pkl":   "abstract module Base\nhost: String",
            "mem:config.pkl": #"amends "mem:base.pkl"\nhost = "localhost""#,
        ])
        let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        let output = try await evaluator.evaluateOutputText(source: .uri("mem:config.pkl")!)
        XCTAssertEqual(output, "host = \"localhost\"\n")
        try await evaluator.close()
    }

    /// `import*(...)` glob resolves to all matching virtual modules, sorted deterministically.
    func testInMemoryModuleReaderGlobImport() async throws {
        let reader = InMemoryModuleReader([
            "mem:/birds/swallow.pkl": "name = \"Swallow\"\nnumberOfEggs = 8",
            "mem:/birds/penguin.pkl": "name = \"Penguin\"\nnumberOfEggs = 1",
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

    /// Requesting a URI not present in the dictionary throws `InMemoryModuleReaderError.moduleNotFound`.
    func testInMemoryModuleReaderModuleNotFound() async throws {
        let reader = InMemoryModuleReader([:])
        let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        do {
            _ = try await evaluator.evaluateOutputText(source: .uri("mem:missing.pkl")!)
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertTrue(
                "\(error)".contains("mem:missing.pkl"),
                "Error message should mention the missing URI; got: \(error)"
            )
        }
        try await evaluator.close()
    }

    /// A reader initialised with a non-default scheme is registered and evaluated correctly.
    func testInMemoryModuleReaderCustomScheme() async throws {
        let reader = InMemoryModuleReader(
            ["virtual:config.pkl": "answer = 42"],
            scheme: "virtual"
        )
        let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
        let evaluator = try await manager.newEvaluator(options: options)
        let output = try await evaluator.evaluateOutputText(source: .uri("virtual:config.pkl")!)
        XCTAssertEqual(output, "answer = 42\n")
        try await evaluator.close()
    }

    /// `listElements` returns only *direct* children of the requested URI,
    /// not grandchildren, so that glob patterns resolve one level at a time.
    func testInMemoryModuleReaderListElementsDirectChildrenOnly() async throws {
        let reader = InMemoryModuleReader([
            "mem:/a/b/deep.pkl": "x = 1",
            "mem:/a/shallow.pkl": "y = 2",
            "mem:/other.pkl": "z = 3",
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
