//===----------------------------------------------------------------------===//
// Copyright © 2024-2025 Apple Inc. and the Pkl project authors. All rights reserved.
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

let pklDebug = ProcessInfo.processInfo.environment["PKL_DEBUG"] == "1"

func debug(_ message: @autoclosure @Sendable () -> String) {
    if !pklDebug {
        return
    }
    FileHandle.standardError.write("[pkl-swift] \(message())\n".data(using: .utf8)!)
    try? FileHandle.standardError.synchronize()
}

let longNumberFormatter: NumberFormatter = {
    let ret = NumberFormatter()
    ret.minimumFractionDigits = 0
    ret.maximumFractionDigits = 10000
    return ret
}()

@Sendable func format(fractional: some BinaryFloatingPoint) -> String? {
    longNumberFormatter.string(from: NSNumber(value: Float64(fractional)))
}

/// Things that can be tested for equality, even if they may have different types
public protocol DynamicallyEquatable: Equatable {
    func isDynamicallyEqual(to other: (any DynamicallyEquatable)?) -> Bool
}

/// The implementation of `isDynamicallyEqual` varies only with the meaning of `Self`, so can be implemented once and for all.
extension DynamicallyEquatable {
    public func isDynamicallyEqual(to other: (any DynamicallyEquatable)?) -> Bool {
        if let value = other as? Self {
            return self == value
        } else {
            return false
        }
    }
}

/// Compares two arrays for equality based on the predicate
public func arrayEquals(arr1: [any DynamicallyEquatable], arr2: [any DynamicallyEquatable]) -> Bool {
    if arr1.count != arr2.count { return false }
    return zip(arr1, arr2).allSatisfy { x, y in x.isDynamicallyEqual(to: y) }
}

/// Compares two maps for equality based on the predicate
public func mapEquals<K>(map1: [K: any DynamicallyEquatable], map2: [K: any DynamicallyEquatable]) -> Bool {
    if map1.count != map2.count { return false }
    return map1.allSatisfy { k, v in
        guard let v2 = map2[k] else {
            return false
        }
        return v.isDynamicallyEqual(to: v2)
    }
}

/// Resolves a sequence of paths into an absolute path.
/// If the first path is relative, the result is relative to the current working directory.
public func resolvePaths(_ paths: String...) -> String {
    var result = FileManager.default.currentDirectoryPath
    for path in paths {
        if path.starts(with: "/") || URL(fileURLWithPath: path).path == path {
            result = path
        } else {
            result = NSString.path(withComponents: [result, path])
        }
    }
    return result
}

public nonisolated(unsafe) let absoluteUriRegex = try! Regex("\\w+:")

public func tempDir() throws -> URL {
    try (FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: URL(fileURLWithPath: "/"), create: true))
}

public func tempFile(suffix: String) throws -> URL {
    let fileName = ProcessInfo.processInfo.globallyUniqueString + suffix
    return try (tempDir()).appendingPathComponent(fileName)
}
