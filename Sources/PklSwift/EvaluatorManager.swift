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

import Foundation
import MessagePack

/// Perfoms `action`, returns its result and then closes the manager.
///
/// - Parameter action: The action to perform
/// - Returns: The result of `action`
public func withEvaluatorManager<T>(_ action: (EvaluatorManager) async throws -> T) async rethrows -> T {
    let manager: EvaluatorManager = .init()
    var closed = false
    do {
        let result = try await action(manager)
        await manager.close()
        closed = true
        return result
    } catch {
        if !closed {
            await manager.close()
        }
        throw error
    }
}

/// Provides handlers for managing the lifecycles of Pkl evaluators. If binding to Pkl as a child process, an evaluator
/// manager represents a single child process.
///
/// If spawning multiple evaluators, it is much better to spawn them through the evaluator manager, rather than through
/// ``withEvaluator(_:)``.
/// This lessens the overhead of each new evaluator, and allows Pkl to cache and optimize evaluation.
public actor EvaluatorManager {
    /// The underlying transport for sending messages,
    var transport: MessageTransport

    /// The created evaluators, identified by their evaluator id.
    var evaluators: [Int64: Evaluator] = [:]

    /// Requests sent to Pkl,
    var inFlightRequests: [Int64: CheckedContinuation<ServerResponseMessage, Error>] = [:]

    var isClosed: Bool = false

    // note; when our C bindings are released, change `init()` based on compiler flags.
    public init() {
        self.init(transport: ChildProcessMessageTransport())
    }

    // Used for testing only.
    init(transport: MessageTransport) {
        self.transport = transport
        Task {
            do {
                try await self.listenForIncomingMessages()
            } catch {
                await self.closeError(error: error)
            }
        }
    }

    private func listenForIncomingMessages() async throws {
        for try await message in try self.transport.getMessages() {
            debug("EvaluatorManager got message \(message)")
            switch message {
            case let message as ServerResponseMessage:
                guard let handler = inFlightRequests.removeValue(forKey: message.requestId) else {
                    // if the handler doesn't exist, this means that ``closeError`` was called, which interrupts all
                    // asks.
                    return
                }
                handler.resume(returning: message)
            case let message as ReadModuleRequest:
                guard let evaluator = evaluators[message.evaluatorId] else {
                    throw PklBugError.invalidEvaluatorId("Received request for unknown evaluator id \(message.evaluatorId)")
                }
                try await evaluator.handleReadModuleRequest(request: message)
            case let message as ReadResourceRequest:
                guard let evaluator = evaluators[message.evaluatorId] else {
                    throw PklBugError.invalidEvaluatorId("Received request for unknown evaluator id \(message.evaluatorId)")
                }
                try await evaluator.handleReadResourceRequest(request: message)
            case let message as LogMessage:
                guard let evaluator = evaluators[message.evaluatorId] else {
                    throw PklBugError.invalidEvaluatorId("Received request for unknown evaluator id \(message.evaluatorId)")
                }
                evaluator.handleLog(request: message)
            case let message as ListModulesRequest:
                guard let evaluator = evaluators[message.evaluatorId] else {
                    throw PklBugError.invalidEvaluatorId("Received request for unknown evaluator id \(message.evaluatorId)")
                }
                try await evaluator.handleListModulesRequest(request: message)
            case let message as ListResourcesRequest:
                guard let evaluator = evaluators[message.evaluatorId] else {
                    throw PklBugError.invalidEvaluatorId("Received request for unknown evaluator id \(message.evaluatorId)")
                }
                try await evaluator.handleListResourcesRequest(request: message)
            default:
                throw PklBugError.unknownMessage("Got request for unknown message: \(message)")
            }
        }
    }

    /// Convenience method for calling ``withEvaluator(_:)`` with preconfigured evaluator options.
    public func withEvaluator<T>(_ action: (Evaluator) async throws -> T) async throws -> T {
        try await self.withEvaluator(options: .preconfigured, action)
    }

    /// Constructs an evaluator with the provided options, and calls the action.
    ///
    /// After the action completes or throws, the evaluator is closed.
    ///
    /// - Parameters:
    ///   - options: The options used to configure the evaluator.
    ///   - action: The action to run with the evaluator.
    public func withEvaluator<T>(options: EvaluatorOptions, _ action: (Evaluator) async throws -> T) async throws -> T {
        let evalautor = try await newEvaluator(options: options)
        var closed = false
        do {
            let result = try await action(evalautor)
            try await evalautor.close()
            closed = true
            return result
        } catch {
            if !closed {
                try await evalautor.close()
            }
            throw error
        }
    }

    /// Convenience method for constructing a project evaluator with preconfigured base options.
    public func withProjectEvaluator<T>(projectBaseURI: URL, _ action: (Evaluator) async throws -> T) async throws -> T {
        try await self.withProjectEvaluator(projectBaseURI: projectBaseURI, options: .preconfigured, action)
    }

    /// Constructs an evaluator that is configured by the project within the project dir.
    ///
    /// `options` is the base set of evaluator options.
    ///  Any `evaluatorSettings` set within the PklProject file overwrites any fields set on `options`.
    ///
    /// After the action completes or throws, the evaluator is closed.
    ///
    /// - Parameters:
    ///   - projectBaseURI: The project base path that contains the PklProject file.
    ///   - options: The options used to configure the evaluator.
    ///   - action: The action to run with the evaluator.
    public func withProjectEvaluator<T>(projectBaseURI: URL, options: EvaluatorOptions, _ action: (Evaluator) async throws -> T) async throws -> T {
        let evaluator = try await newProjectEvaluator(projectBaseURI: projectBaseURI, options: options)
        var closed = false
        do {
            let result = try await action(evaluator)
            try await evaluator.close()
            closed = true
            return result
        } catch {
            if !closed {
                try await evaluator.close()
            }
            throw error
        }
    }

    /// Creates a new evaluator with the provided options.
    ///
    /// To create an evaluator that understands project dependencies, use
    /// ``newProjectEvaluator(projectBaseURI:options:)``.
    ///
    /// - Parameter options: The options used to configure the evaluator.
    public func newEvaluator(options: EvaluatorOptions) async throws -> Evaluator {
        if self.isClosed {
            throw PklError("The evaluator manager is closed")
        }
        let req = options.toMessage()
        guard let response = try await ask(req) as? CreateEvaluatorResponse else {
            throw PklBugError.invalidMessageCode(
                "Received invalid response to create evaluator request")
        }
        if let error = response.error {
            throw PklError(error)
        }
        let id = response.evaluatorId!
        let evaluator = Evaluator(
            manager: self,
            evaluatorID: id,
            resourceReaders: options.resourceReaders ?? [],
            moduleReaders: options.moduleReaders ?? [],
            logger: options.logger
        )
        self.evaluators[id] = evaluator
        return evaluator
    }

    /// Creates a new evaluator that is configured from the provided project.
    ///
    /// `options` is the base set of evaluator options.
    //  Any `evaluatorSettings` set within the PklProject file overwrites any fields set on `options`.
    ///
    /// - Parameters:
    ///   - projectBaseURI: The project base path containing the `PklProject` file.
    ///   - options: The base options used to configure the evaluator.
    public func newProjectEvaluator(projectBaseURI: URL, options: EvaluatorOptions) async throws -> Evaluator {
        if self.isClosed {
            throw PklError("The evaluator manager is closed")
        }
        return try await self.withEvaluator(options: .preconfigured) { projectEvaluator in
            let project = try await projectEvaluator.evaluateOutputValue(
                source: .path("\(projectBaseURI)/PklProject"),
                asType: Project.self
            )
            return try await self.newEvaluator(options: options.withProject(project))
        }
    }

    func closeEvaluator(_ evaluatorId: Int64) async throws {
        try self.tell(CloseEvaluatorRequest(evaluatorId: evaluatorId))
    }

    private func closeError(error: Error) {
        for (id, req) in self.inFlightRequests {
            self.inFlightRequests.removeValue(forKey: id)
            req.resume(throwing: error)
        }
        self.close()
    }

    /// Closes the evaluator manager, and closes any evaluators that have spawned.
    public func close() {
        self.isClosed = true
        for (evaluatorID, _) in self.evaluators {
            Task { try await self.closeEvaluator(evaluatorID) }
        }
        self.transport.close()
    }

    private func doAsk(
        _ message: ClientRequestMessage, _ onResponse: CheckedContinuation<ServerResponseMessage, Error>
    ) throws {
        self.inFlightRequests[message.requestId] = onResponse
        try self.transport.send(message)
    }

    func ask(_ message: ClientRequestMessage) async throws -> ServerResponseMessage {
        try await withCheckedThrowingContinuation { continuation in
            var msg = message
            msg.requestId = Int64.random(in: Int64.min..<Int64.max)
            do {
                try self.doAsk(msg, continuation)
            } catch {
                self.inFlightRequests.removeValue(forKey: msg.requestId)?.resume(throwing: error)
            }
        }
    }

    func tell(_ message: ClientOneWayMessage) throws {
        try self.transport.send(message)
    }

    func tell(_ message: ClientResponseMessage) throws {
        try self.transport.send(message)
    }
}

public struct PklError: Error {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }
}

enum PklBugError: Error {
    case invalidMessageCode(String)
    case invalidRequestId(String)
    case invalidEvaluatorId(String)
    case unknownMessage(String)
}
