// ===----------------------------------------------------------------------===//
// Copyright © 2024-2025 Apple Inc. and the Pkl project authors. All rights reserved.
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

import SemanticVersion
import XCTest

@testable import PklSwift

class ProjectTest: XCTestCase {
    func testLoadProject() async throws {
        let version = try await SemanticVersion(EvaluatorManager().getVersion())!
        let tempDir = try tempDir()
        let subDir = tempDir.appendingPathComponent("subdir")
        try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true)
        let otherProjectFile = subDir.appendingPathComponent("PklProject")

        try #"""
        amends "pkl:Project"

        package {
          name = "starling"
          baseUri = "package://example.com/starling"
          version = "0.5.0"
          packageZipUrl = "https://example.com/starling/\(version)/starling-\(version).zip"
        }
        """#.write(to: otherProjectFile, atomically: true, encoding: .utf8)

        let file = (try PklSwift.tempDir()).appendingPathComponent("PklProject")

        let httpSetting = version < pklVersion0_26 ? "" : """
        http {
          proxy {
            address = "http://localhost:1"
            noProxy {
              "example.com"
              "foo.bar.org"
            }
          }
        }
        """
        let externalReaderSettings = version < pklVersion0_27 ? "" : """
        externalModuleReaders {
          ["scheme1"] {
            executable = "reader1"
          }
          ["scheme2"] {
            executable = "reader2"
            arguments { "with"; "args" }
          }
        }
        externalResourceReaders {
          ["scheme3"] {
            executable = "reader3"
          }
          ["scheme4"] {
            executable = "reader4"
            arguments { "with"; "args" }
          }
        }
        """
        let httpExpectation = version < pklVersion0_26 ? nil : Http(
            caCertificates: nil,
            proxy: .init(address: "http://localhost:1", noProxy: ["example.com", "foo.bar.org"])
        )
        let externalModuleReadersExpectation = version < pklVersion0_27 ? nil : [
          "scheme1": ExternalReader(executable: "reader1"),
          "scheme2": ExternalReader(executable: "reader2", arguments: ["with", "args"]),
        ]
        let externalResourceReadersExpectation = version < pklVersion0_27 ? nil : [
          "scheme3": ExternalReader(executable: "reader3"),
          "scheme4": ExternalReader(executable: "reader4", arguments: ["with", "args"]),
        ]
        try #"""
        amends "pkl:Project"

        package {
          name = "hawk"
          baseUri = "package://example.com/hawk"
          version = "0.5.0"
          description = "Some project about hawks"
          packageZipUrl = "https://example.com/hawk/\(version)/hawk-\(version).zip"
          authors {
            "Birdy Bird <birdy@bird.com>"
          }
          license = "MIT"
          sourceCode = "https://example.com/my/repo"
          sourceCodeUrlScheme = "https://example.com/my/repo/\(version)%{path}"
          documentation = "https://example.com/my/docs"
          website = "https://example.com/my/website"
          licenseText = """
            # Some License text

            This is my license text
            """
          apiTests {
            "apiTest1.pkl"
            "apiTest2.pkl"
          }
          exclude { "*.exe" }
          issueTracker = "https://example.com/my/issues"
        }

        evaluatorSettings {
          externalProperties {
            ["myprop"] = "1"
          }
          env {
            ["myenv"] = "2"
          }
          allowedModules { "foo:" }
          allowedResources { "bar:" }
          noCache = true
          modulePath { "/bar/baz" }
          timeout = 5.min
          moduleCacheDir = "/bar/buzz"
          rootDir = "/buzzy"
          \#(externalReaderSettings)
          \#(httpSetting)
        }

        dependencies {
          ["foo"] {
            uri = "package://example.com/foo@1.0.0"
          }
          ["starling"] = import("\#(otherProjectFile)")
        }
        """#.write(to: file, atomically: true, encoding: .utf8)
        try await withEvaluator { evaluator in
            let project = try await evaluator.evaluateOutputValue(
                source: .url(file),
                asType: Project.self
            )
            let expectedSettings = PklSwift.PklEvaluatorSettings(
                externalProperties: ["myprop": "1"],
                env: ["myenv": "2"],
                allowedModules: ["foo:"],
                allowedResources: ["bar:"],
                noCache: true,
                modulePath: ["/bar/baz"],
                timeout: .minutes(5),
                moduleCacheDir: "/bar/buzz",
                rootDir: "/buzzy",
                http: httpExpectation,
                externalModuleReaders: externalModuleReadersExpectation,
                externalResourceReaders: externalResourceReadersExpectation
            )
            let expectedPackage = PklSwift.Project.Package(
                name: "hawk",
                baseUri: "package://example.com/hawk",
                version: "0.5.0",
                packageZipUrl: "https://example.com/hawk/0.5.0/hawk-0.5.0.zip",
                description: "Some project about hawks",
                authors: ["Birdy Bird <birdy@bird.com>"],
                website: "https://example.com/my/website",
                documentation: "https://example.com/my/docs",
                sourceCode: "https://example.com/my/repo",
                sourceCodeUrlScheme: "https://example.com/my/repo/0.5.0%{path}",
                license: "MIT",
                licenseText: """
                # Some License text

                This is my license text
                """,
                issueTracker: "https://example.com/my/issues",
                apiTests: ["apiTest1.pkl", "apiTest2.pkl"],
                exclude: ["PklProject", "PklProject.deps.json", ".**", "*.exe"],
                uri: "package://example.com/hawk@0.5.0"
            )
            let expectedDependencies: [String: any PklSwift.DependencyDeclaredInProjectFile] = [
                "foo": Project.RemoteDependency(uri: "package://example.com/foo@1.0.0", checksums: nil),
                "starling": Project(
                    package: .init(
                        name: "starling",
                        baseUri: "package://example.com/starling",
                        version: "0.5.0",
                        packageZipUrl: "https://example.com/starling/0.5.0/starling-0.5.0.zip",
                        description: nil,
                        authors: [],
                        website: nil,
                        documentation: nil,
                        sourceCode: nil,
                        sourceCodeUrlScheme: nil,
                        license: nil,
                        licenseText: nil,
                        issueTracker: nil,
                        apiTests: [],
                        exclude: ["PklProject", "PklProject.deps.json", ".**"],
                        uri: "package://example.com/starling@0.5.0"
                    ),
                    evaluatorSettings: .init(
                        externalProperties: nil,
                        env: nil,
                        allowedModules: nil,
                        allowedResources: nil,
                        noCache: nil,
                        modulePath: nil,
                        timeout: nil,
                        moduleCacheDir: nil,
                        rootDir: nil,
                        http: nil,
                        externalModuleReaders: nil,
                        externalResourceReaders: nil
                    ),
                    projectFileUri: "\(otherProjectFile)",
                    tests: [],
                    dependencies: [:]
                ),
            ]
            XCTAssertEqual(project.evaluatorSettings, expectedSettings)
            XCTAssertEqual(project.package, expectedPackage)
            XCTAssertEqual(project.dependencies.count, 2)
            let foo = project.dependencies["foo"] as! Project.RemoteDependency
            let expectedFoo = expectedDependencies["foo"] as! Project.RemoteDependency
            let starling = project.dependencies["starling"] as! Project
            let expectedStarling = expectedDependencies["starling"] as! Project
            XCTAssertEqual(foo, expectedFoo)
            XCTAssertEqual(starling, expectedStarling)
        }
    }
}
