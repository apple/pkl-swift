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

#if libpkl
import XCTest

@testable import PklSwift

class LibPklClientTest : XCTestCase {
    func testGetVersion() throws {
        let version = try LibPklClient.getVersion()
        XCTAssertTrue(!version.isEmpty)
    }

    func testInitClose() throws {
        let client = try LibPklClient()
        try client.close()
    }

    func testSendGarbageMessage() throws {
        let client = try LibPklClient()
        defer {
            do {
                try client.close()
            } catch {
                print("Failed to close: \(error)")
            }
        }
        do {
            try client.sendMessage(bytes: [1, 2, 3, 4])
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssert("\(error)".contains("Malformed message header"))
        }
    }

    func testSendEmptyMessage() throws {
        let client = try LibPklClient()
        defer {
            do {
                try client.close()
            } catch {
                print("Failed to close: \(error)")
            }
        }
        do {
            try client.sendMessage(bytes: [])
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssert("\(error)".contains("Unexpected end of input"))
        }
    }
}
#endif
