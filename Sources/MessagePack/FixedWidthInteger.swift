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

extension FixedWidthInteger {
    init(bytes: [UInt8]) {
        self =
            bytes.withUnsafeBufferPointer {
                $0.baseAddress!.withMemoryRebound(to: Self.self, capacity: 1) {
                    $0.pointee
                }
            }.bigEndian
    }

    var bytes: [UInt8] {
        let capacity = MemoryLayout<Self>.size
        var mutableValue = self.bigEndian
        return withUnsafePointer(to: &mutableValue) {
            $0.withMemoryRebound(to: UInt8.self, capacity: capacity) {
                Array(UnsafeBufferPointer(start: $0, count: capacity))
            }
        }
    }
}
