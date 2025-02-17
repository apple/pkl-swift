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

/// The Swift representation of `pkl.Project`
public struct Project: PklRegisteredType, Hashable, DependencyDeclaredInProjectFile {
    public static let registeredIdentifier: String = "pkl.Project"

    let package: Package?

    let evaluatorSettings: PklEvaluatorSettings

    let projectFileUri: String

    let tests: [String]

    let dependencies: [String: any DependencyDeclaredInProjectFile]

    public static func ==(lhs: Project, rhs: Project) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.package)
        hasher.combine(self.evaluatorSettings)
        hasher.combine(self.projectFileUri)
        hasher.combine(self.tests)
        for (k, v) in self.dependencies {
            hasher.combine(k)
            hasher.combine(v)
        }
    }
}

public protocol DependencyDeclaredInProjectFile: Hashable, Decodable, Equatable {}

extension Project: Decodable {
    public init(from decoder: Decoder) throws {
        let dec = try decoder.container(keyedBy: PklCodingKey.self)
        let package = try dec.decode(Package?.self, forKey: PklCodingKey(stringValue: "package")!)
        let evaluatorSettings = try dec.decode(PklEvaluatorSettings.self, forKey: PklCodingKey(stringValue: "evaluatorSettings")!)
        let projectFileUri = try dec.decode(String.self, forKey: PklCodingKey(stringValue: "projectFileUri")!)
        let tests = try dec.decode([String].self, forKey: PklCodingKey(stringValue: "tests")!)
        let dependencies = try dec.decode([String: PklAny].self, forKey: PklCodingKey(stringValue: "dependencies")!)
            .mapValues { $0.value as! any DependencyDeclaredInProjectFile }
        self = .init(
            package: package,
            evaluatorSettings: evaluatorSettings,
            projectFileUri: projectFileUri,
            tests: tests,
            dependencies: dependencies
        )
    }
}

extension Project {
    /// The Swift representation of `pkl.Project#RemoteDependency`
    public struct RemoteDependency: PklRegisteredType, DependencyDeclaredInProjectFile, Decodable, Hashable {
        public static let registeredIdentifier: String = "pkl.Project#RemoteDependency"

        let uri: String
        let checksums: Checksums?
    }

    /// The Swift representation of `pkl.Project#Package`
    public struct Package: PklRegisteredType, Hashable {
        public static let registeredIdentifier: String = "pkl.Project#Package"

        let name: String
        let baseUri: String
        let version: String
        let packageZipUrl: String
        let description: String?
        let authors: [String]
        let website: String?
        let documentation: String?
        let sourceCode: String?
        let sourceCodeUrlScheme: String?
        let license: String?
        let licenseText: String?
        let issueTracker: String?
        let apiTests: [String]
        let exclude: [String]
        let uri: String
    }

    @available(
        *,
        deprecated,
        message: "Replaced by PklEvaluatorSettings, independent of Project",
        renamed: "PklEvaluatorSettings"
    )
    public typealias EvaluatorSettings = PklEvaluatorSettings
}
