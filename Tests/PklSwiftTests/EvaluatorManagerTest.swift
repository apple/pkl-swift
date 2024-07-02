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

import SemanticVersion
import XCTest

@testable import PklSwift

class FakeMessageTransport: MessageTransport {
    var outboundStream: AsyncThrowingStream<PklSwift.ServerMessage, Error>!

    var outboundContinuation: AsyncThrowingStream<PklSwift.ServerMessage, Error>.Continuation!

    var inboundStream: AsyncStream<PklSwift.ClientMessage>!

    var inboundContinuation: AsyncStream<PklSwift.ClientMessage>.Continuation!

    init() {
        self.outboundStream = AsyncThrowingStream { continuation in
            self.outboundContinuation = continuation
        }
        self.inboundStream = AsyncStream { continuation in
            self.inboundContinuation = continuation
        }
    }

    func send(_ message: PklSwift.ClientMessage) throws {
        self.inboundContinuation.yield(message)
    }

    func getMessages() throws -> AsyncThrowingStream<PklSwift.ServerMessage, Error> {
        self.outboundStream
    }

    func close() {
        // no-op
    }
}

class EvaluatorManagerTest: XCTestCase {
    func testConcurrentEvaluatorManagers() async throws {
        let manager1 = EvaluatorManager()
        let manager2 = EvaluatorManager()
        let manager3 = EvaluatorManager()
        async let evaluator1 = try manager1.newEvaluator(options: .preconfigured).evaluateOutputText(source: .text("res = \"evaluator 1\""))
        async let evaluator2 = try manager2.newEvaluator(options: .preconfigured).evaluateOutputText(source: .text("res = \"evaluator 2\""))
        async let evaluator3 = try manager3.newEvaluator(options: .preconfigured).evaluateOutputText(source: .text("res = \"evaluator 3\""))
        let (result1, result2, result3) = try await (evaluator1, evaluator2, evaluator3)
        XCTAssertEqual(result1, "res = \"evaluator 1\"\n")
        XCTAssertEqual(result2, "res = \"evaluator 2\"\n")
        XCTAssertEqual(result3, "res = \"evaluator 3\"\n")
        await manager1.close()
        await manager2.close()
        await manager3.close()
    }

    func testConcurrentEvaluations() async throws {
        let manager = EvaluatorManager()
        let evaluator = try await manager.newEvaluator(options: .preconfigured)
        async let task1 = try evaluator.evaluateOutputText(source: .text("res = 1"))
        async let task2 = try evaluator.evaluateOutputText(source: .text("res = 2"))
        async let task3 = try evaluator.evaluateOutputText(source: .text("res = 3"))
        let (result1, result2, result3) = try await (task1, task2, task3)
        XCTAssertEqual(result1, "res = 1\n")
        XCTAssertEqual(result2, "res = 2\n")
        XCTAssertEqual(result3, "res = 3\n")
        await manager.close()
    }

    func testInterruptionDuringNewEvaluator() async throws {
        let transport = FakeMessageTransport()
        let manager = EvaluatorManager(transport: transport)
        Task {
            let _ = await transport.inboundStream.first(where: { _ in true }) as! CreateEvaluatorRequest
            transport.outboundContinuation?.finish(throwing: PklError("Something weird happened man."))
        }
        do {
            _ = try await manager.newEvaluator(options: .preconfigured)
        } catch {
            XCTAssertTrue(error is PklError)
            let error = error as! PklError
            XCTAssertEqual(error.message, "Something weird happened man.")
        }
    }

    func testInterruptionDuringEvaluation() async throws {
        let transport = FakeMessageTransport()
        let manager = EvaluatorManager(transport: transport)
        Task {
            let req = await transport.inboundStream.first(where: { _ in true }) as! CreateEvaluatorRequest
            transport.outboundContinuation.yield(CreateEvaluatorResponse(requestId: req.requestId, evaluatorId: 1, error: nil))
            let evaluatedRequest = await transport.inboundStream.first(where: { _ in true }) as! EvaluateRequest
            transport.outboundContinuation.yield(EvaluateResponse(requestId: evaluatedRequest.requestId, evaluatorId: 1, result: nil, error: "Something really weird happened man."))
        }
        do {
            let evaluator = try await manager.newEvaluator(options: .preconfigured)
            _ = try await evaluator.evaluateOutputText(source: .text("foo = 1"))
            XCTFail("Should have thrown")
        } catch {
            XCTAssertTrue(error is PklError)
            let error = error as! PklError
            XCTAssertEqual(error.message, "Something really weird happened man.")
        }
    }

    func testCloseEvaluator() async throws {
        let manager = EvaluatorManager()
        let evaluator = try await manager.newEvaluator(options: .preconfigured)
        _ = try await evaluator.evaluateOutputText(source: .text("foo = 1"))
        try await evaluator.close()
        do {
            _ = try await evaluator.evaluateOutputText(source: .text("foo = 1"))
            XCTFail("Should have thrown")
        } catch {
            XCTAssertTrue(error is PklError)
        }
    }

    func testCloseEvaluatorManager() async throws {
        let manager = EvaluatorManager()
        _ = try await manager.newEvaluator(options: .preconfigured)
        await manager.close()
        do {
            _ = try await manager.newEvaluator(options: .preconfigured)
            XCTFail("Should have thrown")
        } catch {
            XCTAssertTrue(error is PklError)
        }
    }
}
