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

import XCTest
import SemanticVersion
@testable import MessagePack
@testable import PklSwift

class TestLogger: Logger {
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

    var read: (URL) async throws -> String

    var listElements: (URL) async throws -> [PathElement]

    var scheme: String

    var isGlobbable: Bool

    var hasHierarchicalUris: Bool

    var isLocal: Bool
}

struct VirtualResourceReader: ResourceReader {
    var scheme: String

    var isGlobbable: Bool

    var hasHierarchicalUris: Bool

    var read: (URL) async throws -> [UInt8]

    var listElements: (URL) async throws -> [PathElement]

    func read(url: URL) async throws -> [UInt8] {
        try await self.read(url)
    }

    func listElements(uri: URL) async throws -> [PathElement] {
        try await self.listElements(uri)
    }
}

final class PklSwiftTests: XCTestCase {
    var manager: EvaluatorManager!

    override func setUp() {
        self.manager = EvaluatorManager()
    }

    override func tearDown() async throws {
        await self.manager.close()
    }

    func testBasicEvaluation() async throws {
        let evaluator = try await manager.newEvaluator(options: EvaluatorOptions.preconfigured)
        let output = try await evaluator.evaluateOutputText(
            source: ModuleSource(uri: URL(string: "repl:text")!, text: "foo = 1"))
        XCTAssertEqual(output, "foo = 1\n")
    }

    func testVersionCoverage() async throws {
        let output = try getVersion()
        XCTAssert(supportedPklVersions.contains { $0.major == output.major && $0.minor == output.minor })
    }

    func testCustomProxyOptions() async throws {
        let version = try getVersion()
        let expected = version < pklVersion0_26
                ? "http options are not supported on Pkl versions lower than 0.26"
                : "ConnectException: Error connecting to host `example.com`"
        var options = EvaluatorOptions.preconfigured
        options.http = Http(
                caCertificates: nil,
                proxy: Proxy(
                        address: "http://my.proxy.example.com:5080",
                        noProxy: ["myhost.com:1337", "myotherhost.org:42"]))
        var err = nil as Error?
        do {
            let evaluator = try await manager.newEvaluator(options: options)
            let _ = try await evaluator.evaluateOutputText(source: .uri("https://example.com")!)
        } catch {
            err = error
        }
        XCTAssertNotNil(err)
        XCTAssert("\(err!)".contains(expected))
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
        async let evalResult1 = try Task {
            let evaluator = try await self.manager.newEvaluator(options: .preconfigured)
            return try await evaluator.evaluateOutputText(source: .text("foo = 1"))
        }.result.get()

        async let evalResult2 = try Task {
            let evaluator = try await self.manager.newEvaluator(options: .preconfigured)
            return try await evaluator.evaluateOutputText(source: .text("foo = 2"))
        }.result.get()

        async let evalResult3 = try Task {
            let evaluator = try await self.manager.newEvaluator(options: .preconfigured)
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

    func testLogger() async throws {
        var options = EvaluatorOptions.preconfigured
        let logger = TestLogger()
        options.logger = logger
        let evaluator = try await manager.newEvaluator(options: options)
        _ = try await evaluator.evaluateOutputText(source: .text(#"result = let (_ = trace("Hello there")) 1"#))
        XCTAssertEqual(logger.logLines, [#"pkl: TRACE: "Hello there" = "Hello there" (repl:text)\#n"#])
    }

// TODO re-enable this test when packages are available
//
//    func testWithProject() async throws {
//        let project1Dir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("project1")
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
}
