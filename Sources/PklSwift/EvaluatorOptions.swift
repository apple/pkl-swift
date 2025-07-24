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

public struct EvaluatorOptions {
    public init(
        allowedModules: [String]? = nil,
        allowedResources: [String]? = nil,
        resourceReaders: [ResourceReader]? = nil,
        moduleReaders: [ModuleReader]? = nil,
        modulePaths: [String]? = nil,
        env: [String: String]? = nil,
        properties: [String: String]? = nil,
        timeout: Swift.Duration? = nil,
        rootDir: String? = nil,
        cacheDir: String? = nil,
        outputFormat: String? = nil,
        logger: Logger = Loggers.noop,
        projectBaseURI: URL? = nil,
        http: Http? = nil,
        declaredProjectDependencies: [String: ProjectDependency]? = nil,
        externalModuleReaders: [String: ExternalReader]? = nil,
        externalResourceReaders: [String: ExternalReader]? = nil
    ) {
        self.allowedModules = allowedModules
        self.allowedResources = allowedResources
        self.resourceReaders = resourceReaders
        self.moduleReaders = moduleReaders
        self.modulePaths = modulePaths
        self.env = env
        self.properties = properties
        self.timeout = timeout
        self.rootDir = rootDir
        self.cacheDir = cacheDir
        self.outputFormat = outputFormat
        self.logger = logger
        self.projectBaseURI = projectBaseURI
        self.http = http
        self.declaredProjectDependencies = declaredProjectDependencies
        self.externalModuleReaders = externalModuleReaders
        self.externalResourceReaders = externalResourceReaders
    }

    /// Regular expression patterns that control what modules are allowed to be imported in a Pkl program.
    public var allowedModules: [String]?

    /// Regular expression patterns that control what resources are allowed to be read in a Pkl program.
    public var allowedResources: [String]?

    /// Readers that allow importing custom modules in Pkl.
    public var resourceReaders: [ResourceReader]?

    /// Readers that allow reading custom resources in Pkl.
    public var moduleReaders: [ModuleReader]?

    /// The set of zip files, or directories, that get passed to the `modulepath:` scheme.
    public var modulePaths: [String]?

    /// The set of environment variables that can be read using the `env:` scheme.
    public var env: [String: String]?

    /// The set of properties that can be read using the `prop:` scheme.
    public var properties: [String: String]?

    /// The evaluation timeout.
    public var timeout: Swift.Duration?

    /// The root directory for file-based imports and reads.
    ///
    /// If set, forbids reading/importing past the specified directory.
    public var rootDir: String?

    /// The directory in which `package:` modules are cached.
    public var cacheDir: String?

    /// The value of the `pkl.outputFormat` flag.
    ///
    /// Equivalent to the `-f` flag in the CLI.
    public var outputFormat: String?

    /// The logger interface to write trace and warn messages.
    public var logger: Logger

    /// The project directory for the evaluator.
    ///
    /// Setting this determines how Pkl resolves dependency notation imports.
    /// It causes Pkl to look for the resolved dependencies relative to this directory,
    /// and load resolved dependencies from a PklProject.deps.json file inside this directory.
    ///
    /// NOTE:
    /// Setting this option is not equivalent to setting the `--project-dir` flag from the CLI.
    /// When the `--project-dir` flag is set, the CLI will evaluate the PklProject file,
    /// and then applies any evaluator settings and dependencies set in the PklProject file
    /// for the main evaluation.
    ///
    /// In contrast, this option only determines how Pkl considers whether files are part of a
    /// project.
    /// It is meant to be set by lower level logic in Swift code that first evaluates the PklProject,
    /// which then configures ``EvaluatorOptions`` accordingly.
    ///
    /// To emulate the CLI's `--project-dir` flag, create an evaluator with ``withProjectEvaluator(projectBaseURI:_:)``,
    /// or ``EvaluatorManager/newProjectEvaluator()``.
    public var projectBaseURI: URL?

    /// Settings that control how Pkl talks to HTTP(S) servers.
    ///
    /// Added in Pkl 0.26.
    /// These fields are ignored if targeting Pkl 0.25.
    public var http: Http?

    /// The set of dependencies available to modules within ``projectBaseURI``.
    ///
    /// When importing dependencies, a `PklProject.deps.json` file must exist within ``projectBaseURI``
    /// that contains the project's resolved dependencies.
    public var declaredProjectDependencies: [String: ProjectDependency]?

    /// Registered external commands that implement module reader schemes.
    ///
    /// Added in Pkl 0.27.
    /// If the underlying Pkl does not support external readers, evaluation will fail when a registered scheme is used.
    public var externalModuleReaders: [String: ExternalReader]?

    /// Registered external commands that implement resource reader schemes.
    ///
    /// Added in Pkl 0.27.
    /// If the underlying Pkl does not support external readers, evaluation will fail when a registered scheme is used.
    public var externalResourceReaders: [String: ExternalReader]?
}

extension EvaluatorOptions {
    public static let defaultAllowedModules = [
        "pkl:", "repl:", "file:", "http:", "https:", "modulepath:", "package:", "projectpackage:",
    ]

    public static let defaultAllowedResources = [
        "http:", "https:", "file:", "env:", "prop:", "modulepath:", "package:", "projectpackage:",
    ]

    public static var cacheDir: String {
        resolvePaths(FileManager.default.homeDirectoryForCurrentUser.path, ".pkl/cache")
    }

    public static let preconfigured: EvaluatorOptions = .init(
        allowedModules: defaultAllowedModules,
        allowedResources: defaultAllowedResources,
        env: ProcessInfo.processInfo.environment,
        cacheDir: cacheDir,
        logger: Loggers.noop
    )
}

extension EvaluatorOptions {
    func toMessage() -> CreateEvaluatorRequest {
        .init(
            allowedModules: self.allowedModules,
            allowedResources: self.allowedResources,
            clientModuleReaders: self.moduleReaders?.map { $0.toMessage() },
            clientResourceReaders: self.resourceReaders?.map { $0.toMessage() },
            modulePaths: self.modulePaths,
            env: self.env,
            properties: self.properties,
            timeout: self.timeout,
            rootDir: self.rootDir,
            cacheDir: self.cacheDir,
            outputFormat: self.outputFormat,
            project: self.project(),
            http: self.http,
            externalModuleReaders: self.externalModuleReaders,
            externalResourceReaders: self.externalResourceReaders
        )
    }

    func project() -> ProjectOrDependency? {
        guard let projectBaseURI else {
            return nil
        }
        return .init(
            packageUri: nil,
            type: "project",
            projectFileUri: "\(projectBaseURI.appendingPathComponent("PklProject"))",
            checksums: nil,
            dependencies: self.declaredProjectDependenciesToMessage(self.declaredProjectDependencies)
        )
    }

    func declaredProjectDependenciesToMessage(_ deps: [String: ProjectDependency]?) -> [String: ProjectOrDependency]? {
        guard let deps else {
            return nil
        }
        var ret: [String: ProjectOrDependency] = [:]
        for (k, v) in deps {
            switch v {
            case .local(let localDep):
                ret[k] = .init(
                    packageUri: localDep.uri,
                    type: "local",
                    projectFileUri: localDep.projectFileUri,
                    checksums: nil,
                    dependencies: self.declaredProjectDependenciesToMessage(localDep.dependencies)
                )
            case .remote(let remoteDep):
                ret[k] = .init(
                    packageUri: remoteDep.uri,
                    type: "remote",
                    projectFileUri: nil,
                    checksums: remoteDep.checksums,
                    dependencies: nil
                )
            }
        }
        return ret
    }
}

extension EvaluatorOptions {
    /// Builds options that registers the provided module reader, and allowance to import modules starting with its scheme.
    public func withModuleReader(_ reader: ModuleReader) -> EvaluatorOptions {
        var options = self
        var allowedModules = options.allowedModules ?? []
        allowedModules.append(reader.scheme)
        var moduleReaders = options.moduleReaders ?? []
        moduleReaders.append(reader)
        options.allowedModules = allowedModules
        options.moduleReaders = moduleReaders
        return options
    }

    /// Builds options that registers the provided resource reader, and allowance to read resources starting with its scheme.
    public func withResourceReader(_ reader: ResourceReader) -> EvaluatorOptions {
        var options = self
        var allowedResources = options.allowedResources ?? []
        allowedResources.append(reader.scheme)
        var resourceReaders = options.resourceReaders ?? []
        resourceReaders.append(reader)
        options.allowedResources = allowedResources
        options.resourceReaders = resourceReaders
        return options
    }

    /// Builds options that configures the evaluator with settings set on the project.
    ///
    /// Skips any settings that are nil.
    public func withProjectEvaluatorSettings(_ evaluatorSettings: PklEvaluatorSettings) -> EvaluatorOptions {
        var options = self
        options.properties = evaluatorSettings.externalProperties ?? self.properties
        options.env = evaluatorSettings.env ?? self.env
        options.allowedModules = evaluatorSettings.allowedModules ?? self.allowedModules
        options.allowedResources = evaluatorSettings.allowedResources ?? self.allowedResources
        options.cacheDir = evaluatorSettings.noCache != nil ? nil : (evaluatorSettings.moduleCacheDir ?? self.cacheDir)
        options.rootDir = evaluatorSettings.rootDir ?? self.rootDir
        if let http = evaluatorSettings.http {
            options.http = .init()
            if let proxy = http.proxy {
                options.http!.proxy = .init()
                options.http!.proxy!.noProxy = proxy.noProxy ?? self.http?.proxy?.noProxy
                options.http!.proxy!.address = proxy.address ?? self.http?.proxy?.address
            }
            options.http!.rewrites = http.rewrites ?? self.http?.rewrites
        }
        options.externalModuleReaders = evaluatorSettings.externalModuleReaders ?? options.externalModuleReaders
        options.externalResourceReaders = evaluatorSettings.externalResourceReaders ?? options.externalResourceReaders
        return options
    }

    private func projectDependencies(_ project: Project) -> [String: ProjectDependency] {
        var result: [String: ProjectDependency] = [:]
        for (k, v) in project.dependencies {
            switch v {
            case let project as Project:
                result[k] = .local(
                    .init(
                        // Pkl ensures that all local dependencies have a project section.
                        uri: project.package!.uri,
                        projectFileUri: project.projectFileUri,
                        dependencies: self.projectDependencies(project)
                    )
                )
            case let remoteDependency as Project.RemoteDependency:
                result[k] = .remote(.init(uri: remoteDependency.uri, checksums: remoteDependency.checksums))
            default:
                fatalError("Unreachable code")
            }
        }
        return result
    }

    /// Builds options with dependencies from the input project.
    public func withProjectDependencies(_ project: Project) -> EvaluatorOptions {
        var options = self
        options.projectBaseURI = URL(string: project.projectFileUri)!
        options.projectBaseURI?.deleteLastPathComponent()
        options.declaredProjectDependencies = self.projectDependencies(project)
        return options
    }

    /// Builds options with evaluator settings as well as dependencies from the input project.
    public func withProject(_ project: Project) -> EvaluatorOptions {
        self.withProjectEvaluatorSettings(project.evaluatorSettings)
            .withProjectDependencies(project)
    }
}

public enum ProjectDependency {
    case local(ProjectLocalDependency)
    case remote(ProjectRemoteDependency)
}

extension ProjectDependency: Codable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .local(let dep):
            try dep.encode(to: encoder)
        case .remote(let dep):
            try dep.encode(to: encoder)
        }
    }

    public init(from decoder: Decoder) throws {
        do {
            self = try .local(ProjectLocalDependency(from: decoder))
        } catch {
            self = try .remote(ProjectRemoteDependency(from: decoder))
        }
    }
}

public struct ProjectRemoteDependency: Codable, Hashable {
    let uri: String

    let checksums: Checksums?
}

public struct ProjectLocalDependency: Codable {
    let uri: String

    let projectFileUri: String

    let dependencies: [String: ProjectDependency]
}
