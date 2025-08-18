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

/// A representation of a source for a Pkl module to be evaluated.
public struct ModuleSource: Hashable, Sendable {
    /// The URI of the module.
    let uri: URL

    /// The text contents of the module, if available.
    ///
    // If `nil`, gets resolved by Pkl during evaluation time.
    // If the scheme of the uri matches a ``ModuleReader``, it will be used to resolve the module.
    let text: String?
}

extension ModuleSource {
    /// Creates a ``ModuleSource`` from the given file path component.
    ///
    /// Relative paths are resolved against the current working directory.
    ///
    /// - Parameter path: The file path component.
    public static func path(_ path: String) -> ModuleSource {
        let path = resolvePaths(path)
        return ModuleSource(uri: URL(fileURLWithPath: path), text: nil)
    }

    /// Creates a synthetic ``ModuleSource`` with the given text.
    /// The module is assigned `"repl:text"` as its URI.
    ///
    /// - Parameter text: The text contents of the module.
    public static func text(_ text: String) -> ModuleSource {
        ModuleSource(uri: URL(string: "repl:text")!, text: text)
    }

    /// Creates a ``ModuleSource`` with the given URL.
    ///
    /// - Parameter url: The URL that represents this module source.
    public static func url(_ url: URL) -> ModuleSource {
        ModuleSource(uri: url, text: nil)
    }

    /// Creates a ``ModuleSource`` with the given URI string, or returns `nil` if the URI string is malformed.
    ///
    /// - Parameter string: The URI string, for example, `"https://example.com/foo.pkl"`
    public static func uri(_ string: String) -> ModuleSource? {
        guard let url = URL(string: string) else { return nil }
        return ModuleSource(uri: url, text: nil)
    }
}
