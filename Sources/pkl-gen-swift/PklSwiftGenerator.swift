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
import PklSwift

public struct PklSwiftGenerator {
    private let settings: GeneratorSettings.Module
    private let workingDirectory: String
    private var outputStream: TextOutputStream

    public init(settings: GeneratorSettings.Module, workingDirectory: String, outputStream: TextOutputStream) {
        self.settings = settings
        self.workingDirectory = workingDirectory
        self.outputStream = outputStream
    }

    public mutating func run() async throws {
        var options = EvaluatorOptions.preconfigured
        options.logger = Loggers.standardError
        try await withEvaluator(options: options) { evaluator in
            for pklInputModule in self.settings.inputs ?? [] {
                try await self.runModule(
                    evaluator: evaluator,
                    pklInputModule: pklInputModule
                )
            }
        }
    }

    private mutating func runModule(evaluator: Evaluator, pklInputModule: String) async throws {
        let out = resolvePaths(self.settings.outputPath ?? ".out")
        let moduleToEvaluate = """
        amends "\(self.settings.generateScript!)"

        import "\(pklInputModule)" as theModule

        moduleToGenerate = theModule
        """
        let tempFile = try tempFile(suffix: ".pkl")
        try moduleToEvaluate.write(to: tempFile, atomically: true, encoding: .utf8)
        let files = try await evaluator.evaluateOutputFiles(source: .url(tempFile))
        for (filename, contents) in files {
            let path = resolvePaths(out, filename)
            if self.settings.dryRun == true {
                self.outputStream.write(path + "\n")
                continue
            }
            let dir = path.components(separatedBy: "/").dropLast().joined(separator: "/")
            try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
            try contents.write(toFile: path, atomically: true, encoding: .utf8)
            self.outputStream.write(path + "\n")
        }
    }
}
