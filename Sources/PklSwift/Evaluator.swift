// ===----------------------------------------------------------------------===//
// Copyright © 2023 Apple Inc. and the Pkl project authors. All rights reserved.
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

/// A convenience method for running an action given an evaluator with the supplied evaluator options.
/// After `action` completes, the evaluator is closed.
///
/// - Parameters:
///   - options: The options used to configure the evaluator.
///   - action: The action to perform.
public func withEvaluator<T>(options: EvaluatorOptions, _ action: (Evaluator) async throws -> T) async throws -> T {
    try await withEvaluatorManager { manager in
        let evaluator: Evaluator = try await manager.newEvaluator(options: options)
        return try await action(evaluator)
    }
}

/// Like ``withEvaluator(options:_:)``, but with preconfigured evaluator options.
///
/// - Parameter action: The action to perform
public func withEvaluator<T>(_ action: (Evaluator) async throws -> T) async throws -> T {
    try await withEvaluator(options: .preconfigured, action)
}

/// Like ``withProjectEvaluator(projectDir:options:_:)``, but configured with preconfigured otions.
///
/// - Parameters:
///   - projectDir: The directory containing the PklProject file.
///   - action: The action to perform.
/// - Returns: The result of the action.
public func withProjectEvaluator<T>(
    projectDir: String,
    _ action: (Evaluator) async throws -> T
) async throws -> T {
    try await withProjectEvaluator(projectDir: projectDir, options: .preconfigured, action)
}

/// Convenience method for initializing an evaluator from the project.
///
/// `options` is the base set of evaluator options.
///  Any `evaluatorSettings` set within the PklProject file overwrites any fields set on `options`.
///
/// After `action` completes, the evaluator is closed.
/// - Parameters:
///   - projectDir: The directory containing the PklProject file.
///   - options: The base options used to configure the evaluator.
///   - action: The action to perform.
/// - Returns: The result of the action.
public func withProjectEvaluator<T>(
    projectDir: String,
    options: EvaluatorOptions,
    _ action: (Evaluator) async throws -> T
) async throws -> T {
    try await withEvaluatorManager { manager in
        let evaluator = try await manager.newProjectEvaluator(projectDir: projectDir, options: options)
        return try await action(evaluator)
    }
}

/// The core API for evaluating Pkl modules.
public struct Evaluator {
    private var manager: EvaluatorManager
    private let evaluatorID: Int64
    private let resourceReaders: [ResourceReader]
    private let moduleReaders: [ModuleReader]
    private let logger: Logger

    init(
        manager: EvaluatorManager,
        evaluatorID: Int64,
        resourceReaders: [ResourceReader],
        moduleReaders: [ModuleReader],
        logger: Logger
    ) {
        self.manager = manager
        self.evaluatorID = evaluatorID
        self.resourceReaders = resourceReaders
        self.moduleReaders = moduleReaders
        self.logger = logger
    }

    /// Evaluates the provided module, and decodes the result as type `type`.
    ///
    /// - Parameters:
    ///   - source: The module to be evaluated.
    ///   - type: The type to decode the result as.
    /// - Returns: A value of type `type`.
    /// - Throws: ``PklError`` if an error occurs during evaluation, ``DecodingError`` if an the result could not be decoded into ``type``.
    public func evaluateModule<T>(source: ModuleSource, as type: T.Type) async throws -> T
        where T: Decodable {
        try await self.evaluateExpression(source: source, expression: nil, as: type)
    }

    /// Evaluates the provided module's `output.text` property, and returns the result as a string.
    ///
    /// - Parameters:
    ///   - source: The module source to be evaluated.
    /// - Returns: A string representing the rendered contents of the module.
    /// - Throws: ``PklError`` if an error occurs during evaluation.
    public func evaluateOutputText(source: ModuleSource) async throws -> String {
        try await self.evaluateExpression(source: source, expression: "output.text", as: String.self)
    }

    /// Evaluates the provided module's `output.value` property, and decodes the result as type `type`.
    ///
    /// - Parameters:
    ///   - source: The module to be evaluated.
    ///   - type: The type to decode the result as.
    /// - Returns: The evaluated result as type `type`.
    /// - Throws: ``PklError`` if an error occurs during evaluation, ``DecodingError`` if the result could not be decoded into ``type``.
    public func evaluateOutputValue<T>(source: ModuleSource, asType type: T.Type) async throws -> T
        where T: Decodable {
        try await self.evaluateExpression(source: source, expression: "output.value", as: type)
    }

    /// Evaluates the `output.files` property of the given module.
    ///
    /// - Parameter source: The module to be evaluated.
    /// - Returns: A dictionary whose keys are the filenames, and values are the file contents.
    /// - Throws: ``PklError`` if an error occurs during evaluation.
    public func evaluateOutputFiles(source: ModuleSource) async throws -> [String: String] {
        try await self.evaluateExpression(
            source: source, expression: "output.files.toMap().mapValues((_, it) -> it.text)",
            as: [String: String].self
        )
    }

    /// Evaluates the provided `expression` within `module`, and decodes the result as type `type`.
    ///
    /// - Parameters:
    ///   - source: The module to be evaluated.
    ///   - expression: The expression to be evaluated within the module. If `nil`, evaluates the whole module.
    ///   - type: The type to decode the result as.
    /// - Returns: A value of type `type`.
    /// - Throws: ``PklError`` if an error occurs during evaluation, ``DecodingError`` if the result could not be decoded into ``type``.
    public func evaluateExpression<T>(source: ModuleSource, expression: String?, as type: T.Type)
        async throws -> T where T: Decodable {
        let bytes = try await evaluateExpressionRaw(source: source, expression: expression)
        return try PklDecoder.decode(type, from: bytes)
    }

    /// Evaluates the provided `expression` within the `module`, and returns the underlying response in binary form.
    ///
    /// - Parameters:
    ///   - source: The module to be evaluated
    ///   - expression: The expression to be evaluated within the module. If `nil`, evaluates the whole module.
    /// - Returns: The evaluated result, in binary form.
    /// - Throws: ``PklError``, if an error occured during evaluation
    public func evaluateExpressionRaw(source: ModuleSource, expression: String?) async throws
        -> [UInt8] {
        let request = EvaluateRequest(
            // filled in by ``EvaluatorManager`` later
            requestId: 0,
            evaluatorId: evaluatorID,
            moduleUri: source.uri,
            moduleText: source.text,
            expr: expression
        )
        let response = try await manager.ask(request)
        guard let response = response as? EvaluateResponse else {
            throw PklBugError.invalidMessageCode(
                "Expected EvaluateResponse, but got \(type(of: response))")
        }
        if let error = response.error {
            throw PklError(error)
        }
        // we can be sure that if error is nil, result is set.
        return response.result!
    }

    /// Closes this evaluator, cleaning up any resources held by the evaluator.
    public func close() async throws {
        try await self.manager.closeEvaluator(self.evaluatorID)
    }

    func handleReadModuleRequest(request: ReadModuleRequest) async throws {
        var response = ReadModuleResponse(
            requestId: request.requestId,
            evaluatorId: self.evaluatorID,
            contents: nil,
            error: nil
        )
        guard let reader = moduleReaders.first(where: { $0.scheme == request.uri.scheme }) else {
            response.error = "No module reader found for scheme \(request.uri.scheme!)"
            try await self.manager.tell(response)
            return
        }
        do {
            let result = try await reader.read(url: request.uri)
            response.contents = result
            try await self.manager.tell(response)
        } catch {
            response.error = "\(error)"
            try await self.manager.tell(response)
        }
    }

    func handleReadResourceRequest(request: ReadResourceRequest) async throws {
        var response = ReadResourceResponse(
            requestId: request.requestId,
            evaluatorId: self.evaluatorID,
            contents: nil,
            error: nil
        )
        guard let reader = self.resourceReaders.first(where: { $0.scheme == request.uri.scheme }) else {
            response.error = "No resource reader found for scheme \(request.uri.scheme!)"
            try await self.manager.tell(response)
            return
        }
        do {
            let result = try await reader.read(url: request.uri)
            response.contents = result
            try await self.manager.tell(response)
        } catch {
            response.error = "\(error)"
            try await self.manager.tell(response)
        }
    }

    func handleListModulesRequest(request: ListModulesRequest) async throws {
        var response = ListModulesResponse(
            requestId: request.requestId,
            evaluatorId: self.evaluatorID,
            pathElements: nil,
            error: nil
        )
        guard let reader = moduleReaders.first(where: { $0.scheme == request.uri.scheme }) else {
            response.error = "No module reader found for scheme \(request.uri.scheme!)"
            try await self.manager.tell(response)
            return
        }
        do {
            let elems = try await reader.listElements(uri: request.uri)
            response.pathElements = elems.map { $0.toMessage() }
            try await self.manager.tell(response)
        } catch {
            response.error = "\(error)"
            try await self.manager.tell(response)
        }
    }

    func handleListResourcesRequest(request: ListResourcesRequest) async throws {
        var response = ListResourcesResponse(
            requestId: request.requestId,
            evaluatorId: self.evaluatorID,
            pathElements: nil,
            error: nil
        )
        guard let reader = resourceReaders.first(where: { $0.scheme == request.uri.scheme }) else {
            response.error = "No resource reader found for scheme \(request.uri.scheme!)"
            try await self.manager.tell(response)
            return
        }
        do {
            let elems = try await reader.listElements(uri: request.uri)
            response.pathElements = elems.map { $0.toMessage() }
            try await self.manager.tell(response)
        } catch {
            response.error = "\(error)"
            try await self.manager.tell(response)
        }
    }

    func handleLog(request: LogMessage) {
        switch request.level {
        case .trace:
            self.logger.trace(message: request.message, frameUri: request.frameUri)
        case .warn:
            self.logger.warn(message: request.message, frameUri: request.frameUri)
        }
    }
}
