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

import XCTest

@testable import PklSwift

class DataSizeTests: XCTestCase {
    func testStringify() {
        XCTAssertEqual(String(describing: DataSize.kilobytes(15)), "15.kb")
        XCTAssertEqual(String(describing: DataSize.kilobytes(3.1415926)), "3.1415926.kb")
        XCTAssertEqual(String(describing: DataSize.kilobytes(1_000_000_000_000)), "1000000000000.kb")
    }

    func testToUnit() {
        let oneKb = DataSize.kilobytes(1000)
        XCTAssertEqual(oneKb.toUnit(.mb), .megabytes(1))
        XCTAssertEqual(oneKb.toUnit(.b), .bytes(1_000_000))
        XCTAssertEqual(oneKb.toUnit(.gb), .gigabytes(0.001))
    }
}
