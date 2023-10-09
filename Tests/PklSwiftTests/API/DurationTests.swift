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

import PklSwift
import XCTest

class DurationTests: XCTestCase {
    func testStringify() {
        XCTAssertEqual(String(describing: Duration(42, unit: .ms)), "42.ms")
        XCTAssertEqual(String(describing: Duration(42, unit: .min)), "42.min")
        XCTAssertEqual(String(describing: Duration(42, unit: .d)), "42.d")
    }

    func testToUnit() {
        let phiDays = Duration(1.618, unit: .d)
        XCTAssertEqual(phiDays.toUnit(.h), Duration(38.832, unit: .h))
        XCTAssertEqual(phiDays.toUnit(.minutes), Duration(2329.92, unit: .min))
        XCTAssertEqual(phiDays.toUnit(.milliseconds), Duration(139_795_200, unit: .ms))
    }
}
