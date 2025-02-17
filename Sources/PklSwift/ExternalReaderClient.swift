//===----------------------------------------------------------------------===//
// Copyright © 2025 Apple Inc. and the Pkl project authors. All rights reserved.
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
import MessagePack

// Example usage:
// import PklSwift
// @main
// struct Main {
//     static func main() async throws {
//         let client = ExternalReaderClient(
//             options: ExternalReaderClientOptions(
//                 resourceReaders: [MyResourceReader()]
//             ))
//         try await client.run()
//     }
// }

public struct ExternalReaderClientOptions {
    /// Reader to receive requests.
    public var requestReader: Reader = FileHandle.standardInput

    /// Writer to publish responses.
    public var responseWriter: Writer = FileHandle.standardOutput

    /// Readers that allow reading custom resources in Pkl.
    public var moduleReaders: [ModuleReader] = []

    /// Readers that allow importing custom modules in Pkl.
    public var resourceReaders: [ResourceReader] = []

    public init(
        requestReader: Reader = FileHandle.standardInput,
        responseWriter: Writer = FileHandle.standardOutput,
        moduleReaders: [ModuleReader] = [],
        resourceReaders: [ResourceReader] = []
    ) {
        self.requestReader = requestReader
        self.responseWriter = responseWriter
        self.moduleReaders = moduleReaders
        self.resourceReaders = resourceReaders
    }
}

public class ExternalReaderClient {
    private let moduleReaders: [ModuleReader]
    private let resourceReaders: [ResourceReader]
    private let transport: MessageTransport

    public init(options: ExternalReaderClientOptions) {
        self.moduleReaders = options.moduleReaders
        self.resourceReaders = options.resourceReaders
        self.transport = ExternalReaderMessageTransport(
            reader: options.requestReader, writer: options.responseWriter
        )
    }

    public func run() async throws {
        for try await message in try self.transport.getMessages() {
            switch message {
            case let message as InitializeModuleReaderRequest:
                try self.handleInitializeModuleReaderRequest(request: message)
            case let message as InitializeResourceReaderRequest:
                try self.handleInitializeResourceReaderRequest(request: message)
            case let message as ReadModuleRequest:
                try await self.handleReadModuleRequest(request: message)
            case let message as ReadResourceRequest:
                try await self.handleReadResourceRequest(request: message)
            case let message as ListModulesRequest:
                try await self.handleListModulesRequest(request: message)
            case let message as ListResourcesRequest:
                try await self.handleListResourcesRequest(request: message)
            case _ as CloseExternalProcess:
                self.close()
            default:
                throw PklBugError.unknownMessage("Got request for unknown message: \(message)")
            }
        }
    }

    public func close() {
        self.transport.close()
    }

    func handleInitializeModuleReaderRequest(request: InitializeModuleReaderRequest) throws {
        var response = InitializeModuleReaderResponse(requestId: request.requestId, spec: nil)
        guard let reader = moduleReaders.first(where: { $0.scheme == request.scheme }) else {
            try self.transport.send(response)
            return
        }
        response.spec = reader.toMessage()
        try self.transport.send(response)
    }

    func handleInitializeResourceReaderRequest(request: InitializeResourceReaderRequest) throws {
        var response = InitializeResourceReaderResponse(requestId: request.requestId, spec: nil)
        guard let reader = resourceReaders.first(where: { $0.scheme == request.scheme }) else {
            try self.transport.send(response)
            return
        }
        response.spec = reader.toMessage()
        try self.transport.send(response)
    }

    func handleReadModuleRequest(request: ReadModuleRequest) async throws {
        var response = ReadModuleResponse(
            requestId: request.requestId,
            evaluatorId: request.evaluatorId,
            contents: nil,
            error: nil
        )
        guard let reader = moduleReaders.first(where: { $0.scheme == request.uri.scheme }) else {
            response.error = "No module reader found for scheme \(request.uri.scheme!)"
            try self.transport.send(response)
            return
        }
        do {
            let result = try await reader.read(url: request.uri)
            response.contents = result
            try self.transport.send(response)
        } catch {
            response.error = "\(error)"
            try self.transport.send(response)
        }
    }

    func handleReadResourceRequest(request: ReadResourceRequest) async throws {
        var response = ReadResourceResponse(
            requestId: request.requestId,
            evaluatorId: request.evaluatorId,
            contents: nil,
            error: nil
        )
        guard
            let reader = resourceReaders.first(where: { $0.scheme == request.uri.scheme }) else {
            response.error = "No resource reader found for scheme \(request.uri.scheme!)"
            try self.transport.send(response)
            return
        }
        do {
            let result = try await reader.read(url: request.uri)
            response.contents = result
            try self.transport.send(response)
        } catch {
            response.error = "\(error)"
            try self.transport.send(response)
        }
    }

    func handleListModulesRequest(request: ListModulesRequest) async throws {
        var response = ListModulesResponse(
            requestId: request.requestId,
            evaluatorId: request.evaluatorId,
            pathElements: nil,
            error: nil
        )
        guard let reader = moduleReaders.first(where: { $0.scheme == request.uri.scheme }) else {
            response.error = "No module reader found for scheme \(request.uri.scheme!)"
            try self.transport.send(response)
            return
        }
        do {
            let elems = try await reader.listElements(uri: request.uri)
            response.pathElements = elems.map { $0.toMessage() }
            try self.transport.send(response)
        } catch {
            response.error = "\(error)"
            try self.transport.send(response)
        }
    }

    func handleListResourcesRequest(request: ListResourcesRequest) async throws {
        var response = ListResourcesResponse(
            requestId: request.requestId,
            evaluatorId: request.evaluatorId,
            pathElements: nil,
            error: nil
        )
        guard
            let reader = resourceReaders.first(where: { $0.scheme == request.uri.scheme }) else {
            response.error = "No resource reader found for scheme \(request.uri.scheme!)"
            try self.transport.send(response)
            return
        }
        do {
            let elems = try await reader.listElements(uri: request.uri)
            response.pathElements = elems.map { $0.toMessage() }
            try self.transport.send(response)
        } catch {
            response.error = "\(error)"
            try self.transport.send(response)
        }
    }
}
