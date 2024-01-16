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

import ArgumentParser
import Foundation
import PklSwift

let VERSION = String(decoding: Data(PackageResources.VERSION_txt), as: UTF8.self)

struct ConsoleOutputStream: TextOutputStream {
    mutating func write(_ string: String) {
        print(string, terminator: "")
    }
}

private func normalizeModule(input: String) -> String {
    if input.starts(with: absoluteUriRegex) {
        return input
    } else {
        return resolvePaths(input)
    }
}

extension GeneratorSettings {
    static let EMPTY = GeneratorSettings.Module(
        inputs: [],
        outputPath: nil,
        dryRun: nil,
        generateScript: nil
    )
}

@main
struct PklGenSwift: AsyncParsableCommand {
    // Hidden because this is really only meant for internal use.
    @Option(name: .long, help: .hidden)
    var generateScript: String?

    @Option(
        name: .shortAndLong,
        help: "The output directory to write generated sources into",
        completion: .directory
    )
    var outputPath: String?

    @Flag(help: "Print the names of the files that will be generated, but don't write any files")
    var dryRun: Bool = false

    @Flag(help: "Print the version and exit")
    var version: Bool = false

    @Option(
        name: .long,
        help: "The generator-settings.pkl file to use",
        completion: .file(extensions: ["pkl"]),
        transform: normalizeModule
    )
    var generatorSettings: String?

    @Argument(
        help: "The Pkl modules to generate as Swift",
        completion: .file(extensions: [".pkl"]),
        transform: normalizeModule
    )
    var pklInputModules: [String] = []

    func tempFile() -> URL {
        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".pkl"
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
    }

    private func generateScriptUrl() -> String {
        if let generateScript = self.generateScript {
            return URL(fileURLWithPath: generateScript).path
        } else {
            // TODO(oss) // confirm this
            return "package://pkg.pkl-lang.org/pkl-swift/pkl.swift@\(VERSION)#/Generator.pkl"
        }
    }

    private func getGeneratorSettingsFile() -> String? {
        if let settingsFile = self.generatorSettings {
            return settingsFile
        }
        if FileManager.default.fileExists(atPath: "generator-settings.pkl") {
            return "generator-settings.pkl"
        }
        return nil
    }

    private func loadGeneratorSettings() async throws -> GeneratorSettings.Module {
        guard let settingsFile = getGeneratorSettingsFile() else {
            return GeneratorSettings.EMPTY
        }
        var options = EvaluatorOptions.preconfigured
        options.logger = Loggers.standardError
        return try await withEvaluator(options: options) { evaluator in
            try await evaluator.evaluateOutputValue(
                source: .path(settingsFile),
                asType: GeneratorSettings.Module.self
            )
        }
    }

    private func buildGeneratorSettings() async throws -> GeneratorSettings.Module {
        var generatorSettings = try await loadGeneratorSettings()
        if !self.pklInputModules.isEmpty {
            generatorSettings.inputs = self.pklInputModules
        }
        if self.dryRun == true {
            generatorSettings.dryRun = true
        }
        if let outputPath = self.outputPath {
            generatorSettings.outputPath = outputPath
        }
        generatorSettings.generateScript = self.generateScriptUrl()
        return generatorSettings
    }

    mutating func run() async throws {
        if self.version {
            print(VERSION)
            Self.exit()
        }
        let settings = try await buildGeneratorSettings()
        if settings.dryRun == true {
            FileHandle.standardError.write(Data("Running in dry-run mode\n".utf8))
        }
        do {
            var cmd = PklSwiftGenerator(
                settings: settings,
                workingDirectory: FileManager.default.currentDirectoryPath,
                outputStream: ConsoleOutputStream()
            )
            try await cmd.run()
        } catch let error as PklError {
            Self.exit(withError: error)
        }
    }
}
