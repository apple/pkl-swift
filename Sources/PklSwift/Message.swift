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
import MessagePack

protocol Message: Codable {}

protocol OneWayMessage: Message {}

protocol RequestMessage: Message {
    var requestId: Int64 { get set }
}

protocol ResponseMessage: Message {
    var requestId: Int64 { get }
}

protocol ClientMessage: Message {}

protocol ClientRequestMessage: ClientMessage, RequestMessage {}

protocol ClientResponseMessage: ClientMessage, ResponseMessage {}

protocol ClientOneWayMessage: ClientMessage, OneWayMessage {}

protocol ServerMessage: Message, Decodable {}

protocol ServerRequestMessage: ServerMessage, RequestMessage {}

protocol ServerResponseMessage: ServerMessage, ResponseMessage {}

protocol ServerOneWayMessage: ServerMessage, OneWayMessage {}

struct ModuleReaderSpec: Codable {
    let scheme: String
    let hasHierarchicalUris: Bool
    let isLocal: Bool
    let isGlobbable: Bool
}

struct ResourceReaderSpec: Codable {
    let scheme: String
    let hasHierarchicalUris: Bool
    let isGlobbable: Bool
}

enum MessageType: Int, Codable {
    case CREATE_EVALUATOR_REQUEST = 0x20
    case CREATE_EVALUATOR_RESPONSE = 0x21
    case CLOSE_EVALUATOR = 0x22
    case EVALUATOR_REQUEST = 0x23
    case EVALUATOR_RESPOSNE = 0x24
    case LOG_MESSAGE = 0x25
    case READ_RESOURCE_REQUEST = 0x26
    case READ_RESOURCE_RESPONSE = 0x27
    case READ_MODULE_REQUEST = 0x28
    case READ_MODULE_RESPONSE = 0x29
    case LIST_RESOURCES_REQUEST = 0x2A
    case LIST_RESOURCES_RESPONSE = 0x2B
    case LIST_MODULES_REQUEST = 0x2C
    case LIST_MODULES_RESPONSE = 0x2D
}

extension MessageType {
    static func getMessageType(_ message: Message) -> MessageType {
        switch message {
        case is CreateEvaluatorRequest:
            return MessageType.CREATE_EVALUATOR_REQUEST
        case is CreateEvaluatorResponse:
            return MessageType.CREATE_EVALUATOR_RESPONSE
        case is CloseEvaluatorRequest:
            return MessageType.CLOSE_EVALUATOR
        case is EvaluateRequest:
            return MessageType.EVALUATOR_REQUEST
        case is EvaluateResponse:
            return MessageType.EVALUATOR_RESPOSNE
        case is LogMessage:
            return MessageType.LOG_MESSAGE
        case is ListResourcesRequest:
            return MessageType.LIST_RESOURCES_REQUEST
        case is ListResourcesResponse:
            return MessageType.LIST_MODULES_RESPONSE
        case is ListModulesRequest:
            return MessageType.LIST_MODULES_REQUEST
        case is ListModulesResponse:
            return MessageType.LIST_MODULES_RESPONSE
        case is ReadModuleResponse:
            return MessageType.READ_MODULE_RESPONSE
        case is ReadResourceResponse:
            return MessageType.READ_RESOURCE_RESPONSE
        default:
            preconditionFailure("Unreachable code")
        }
    }
}

struct CreateEvaluatorRequest: ClientRequestMessage {
    var requestId: Int64 = 0
    var allowedModules: [String]?
    var allowedResources: [String]?
    var clientModuleReaders: [ModuleReaderSpec]?
    var clientResourceReaders: [ResourceReaderSpec]?
    var modulePaths: [String]?
    var env: [String: String]?
    var properties: [String: String]?
    var timeout: Swift.Duration?
    var rootDir: String?
    var cacheDir: String?
    var outputFormat: String?
    var project: ProjectOrDependency?
}

struct ProjectOrDependency: Codable {
    var packageUri: String?
    var type: String
    var projectFileUri: String?
    var checksums: Checksums?
    var dependencies: [String: ProjectOrDependency]?
}

struct Checksums: Codable, Hashable {
    var sha256: String?
}

struct CreateEvaluatorResponse: ServerResponseMessage {
    let requestId: Int64
    let evaluatorId: Int64?
    let error: String?
}

struct ReadResourceRequest: ServerRequestMessage {
    var requestId: Int64
    let evaluatorId: Int64
    let uri: URL
}

struct ReadResourceResponse: ClientResponseMessage {
    var requestId: Int64
    var evaluatorId: Int64
    var contents: [UInt8]?
    var error: String?
}

struct ReadModuleRequest: ServerRequestMessage {
    var requestId: Int64
    let evaluatorId: Int64
    let uri: URL
}

struct ReadModuleResponse: ClientResponseMessage {
    var requestId: Int64
    var evaluatorId: Int64
    var contents: String?
    var error: String?
}

struct ListResourcesRequest: ServerRequestMessage {
    var requestId: Int64
    var evaluatorId: Int64
    var uri: URL
}

struct ListResourcesResponse: ClientResponseMessage {
    var requestId: Int64
    var evaluatorId: Int64
    var pathElements: [PathElementMessage]?
    var error: String?
}

struct PathElementMessage: Codable {
    var name: String
    var isDirectory: Bool
}

struct ListModulesRequest: ServerRequestMessage {
    var requestId: Int64
    var evaluatorId: Int64
    var uri: URL
}

struct ListModulesResponse: ClientResponseMessage {
    var requestId: Int64
    var evaluatorId: Int64
    var pathElements: [PathElementMessage]?
    var error: String?
}

struct CloseEvaluatorRequest: ClientOneWayMessage {
    var evaluatorId: Int64
}

struct EvaluateRequest: ClientRequestMessage {
    var requestId: Int64
    var evaluatorId: Int64
    var moduleUri: URL
    var moduleText: String?
    var expr: String?
}

struct EvaluateResponse: ServerResponseMessage {
    let requestId: Int64
    let evaluatorId: Int64
    let result: [UInt8]?
    let error: String?
}

enum LogLevel: Int, Codable {
    case trace = 0
    case warn = 1
}

struct LogMessage: ServerOneWayMessage {
    let evaluatorId: Int64
    let level: LogLevel
    let message: String
    // NOTE: not guaranteed to conform to URL. This might have been transformed by a stack frame transformer.
    let frameUri: String
}
