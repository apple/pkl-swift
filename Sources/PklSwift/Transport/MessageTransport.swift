//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the Pkl project authors. All rights reserved.
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

import PklMessagePack

protocol MessageTransport: Sendable {
    /// Send a message to the Pkl server.
    func send(_ message: ClientMessage) throws

    /// Returns a stream that yields messages from the pkl server over time.
    func getMessages() throws -> AsyncThrowingStream<ServerMessage, Error>

    /// Close the transport.
    func close() throws
}

func decodeMessage(from decoder: MessagePackDecoder) throws -> any ServerMessage {
    let arrayLength = try decoder.decodeArrayLength()
    guard arrayLength == 2 else {
        throw PklBugError.invalidMessageCode(
            "Expected 2-element message array, got \(arrayLength)")
    }
    let messageType: MessageType = try decoder.decode(as: MessageType.self)
    switch messageType {
    case .READ_MODULE_REQUEST:
        return try decoder.decode(as: ReadModuleRequest.self)
    case .READ_RESOURCE_REQUEST:
        return try decoder.decode(as: ReadResourceRequest.self)
    case .LIST_MODULES_REQUEST:
        return try decoder.decode(as: ListModulesRequest.self)
    case .LIST_RESOURCES_REQUEST:
        return try decoder.decode(as: ListResourcesRequest.self)
    case .CREATE_EVALUATOR_RESPONSE:
        return try decoder.decode(as: CreateEvaluatorResponse.self)
    case .EVALUATE_RESPONSE:
        return try decoder.decode(as: EvaluateResponse.self)
    case .LOG_MESSAGE:
        return try decoder.decode(as: LogMessage.self)
    case .INITIALIZE_MODULE_READER_REQUEST:
        return try decoder.decode(as: InitializeModuleReaderRequest.self)
    case .INITIALIZE_RESOURCE_READER_REQUEST:
        return try decoder.decode(as: InitializeResourceReaderRequest.self)
    case .CLOSE_EXTERNAL_PROCESS:
        return try decoder.decode(as: CloseExternalProcess.self)
    default:
        throw PklBugError.invalidMessageCode("Unexpected message code from Pkl: \(messageType)")
    }
}

extension Message {
    func encode(to encoder: MessagePackEncoder) throws {
        try encoder.encodeArrayHeader(2)
        try encoder.encode(MessageType.getMessageType(self))
        try encoder.encode(self)
    }
}
