//===----------------------------------------------------------------------===//
// Copyright © 2024-2026 Apple Inc. and the Pkl project authors. All rights reserved.
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
import PklSwift

/// A ``ModuleReader`` that serves Pkl modules from an in-memory virtual filesystem.
///
/// `VirtualFileReader` models a hierarchical filesystem: all paths must begin with `/`
/// and path separators (`/`) denote directory structure, just like `file:` or `http:` URIs.
/// This makes it suitable for evaluating multi-file Pkl configurations without touching disk.
///
/// It is particularly useful for:
/// - **Unit testing**: supply known Pkl text without writing temporary files.
/// - **Dynamic configuration**: assemble Pkl modules from runtime data and evaluate them.
/// - **Multi-file setups**: model `amends`/`import` relationships across several virtual modules.
///
/// ## Example
///
/// ```swift
/// let reader = try VirtualFileReader("mem", [
///     "/base.pkl":   "abstract module Base\nhost: String",
///     "/config.pkl": #"amends "mem:/base.pkl"\nhost = "localhost""#,
/// ])
/// let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
/// try await withEvaluator(options: options) { evaluator in
///     let output = try await evaluator.evaluateOutputText(
///         source: .uri("mem:/config.pkl")!
///     )
///     print(output) // host = "localhost"
/// }
/// ```
///
/// ## Path Format
///
/// Keys in the `files` dictionary must be absolute paths beginning with a forward slash,
/// e.g. `"/config.pkl"` or `"/catalog/birds.pkl"`. The initializer throws
/// ``VirtualFileReaderError/invalidPath(_:)`` if any key does not start with `/`.
///
/// When evaluating, reference modules using a URI whose scheme matches the reader's
/// ``scheme`` property, e.g. `"mem:/config.pkl"`.
///
/// ## Glob and Triple-Dot Imports
///
/// Because ``isGlobbable`` and ``isLocal`` are both `true`, Pkl's `import*(...)` and
/// triple-dot (`...`) import syntax both work against the registered files.
/// ``listElements(uri:)`` returns the *direct* children of the given base URI,
/// sorted alphabetically for deterministic output.
public struct VirtualFileReader: ModuleReader {
    // MARK: - Stored properties

    /// The virtual filesystem: a dictionary mapping absolute paths to Pkl source text.
    ///
    /// Keys are absolute paths beginning with `/` (e.g. `"/config.pkl"` or
    /// `"/catalog/swallow.pkl"`). Values are the raw Pkl source text.
    public let files: [String: String]

    /// The URI scheme handled by this reader.
    public let scheme: String

    // MARK: - Initializer

    /// Creates a ``VirtualFileReader`` with the given scheme and file mappings.
    ///
    /// - Parameters:
    ///   - scheme: The URI scheme this reader claims (e.g. `"mem"`).
    ///   - files:  A dictionary whose keys are absolute paths beginning with `/`, and whose
    ///             values are the Pkl source text for that module.
    /// - Throws: ``VirtualFileReaderError/invalidPath(_:)`` if any key does not start with `/`.
    public init(_ scheme: String, _ files: [String: String]) throws {
        for key in files.keys {
            guard key.hasPrefix("/") else {
                throw VirtualFileReaderError.invalidPath(key)
            }
        }
        self.scheme = scheme
        self.files = files
    }

    // MARK: - ModuleReader conformance

    /// `true` — enables `import*(...)` glob syntax against registered files.
    public var isGlobbable: Bool { true }

    /// `true` — path separators (`/`) denote directory structure (hierarchical URIs).
    public var hasHierarchicalUris: Bool { true }

    /// `true` — Pkl treats these modules as local, enabling triple-dot (`...`) resolution.
    public var isLocal: Bool { true }

    /// Returns the Pkl source text for the module at `url`.
    ///
    /// The path is extracted by stripping the `<scheme>:` prefix from the URL's absolute string.
    ///
    /// - Throws: ``VirtualFileReaderError/fileNotFound(_:)`` when no file is registered
    ///   under the resolved path.
    public func read(url: URL) async throws -> String {
        let urlString = url.absoluteString
        guard urlString.hasPrefix(scheme + ":") else {
            throw VirtualFileReaderError.fileNotFound(urlString)
        }

        let path = String(urlString.dropFirst(scheme.count + 1))

        guard let source = files[path] else {
            throw VirtualFileReaderError.fileNotFound(path)
        }
        return source
    }

    /// Returns the direct children of `uri` among all registered file paths.
    ///
    /// The implementation performs a single linear scan of ``files``, strips the
    /// common base-path prefix, and groups results by their first remaining path component.
    /// Directory entries (intermediate path segments) are synthesised automatically.
    /// Output is sorted by name for deterministic glob results.
    public func listElements(uri: URL) async throws -> [PathElement] {
        let urlString = uri.absoluteString
        guard urlString.hasPrefix(scheme + ":") else { return [] }

        let basePath = String(urlString.dropFirst(scheme.count + 1))

        var seen = Set<String>()
        var result: [PathElement] = []

        for key in files.keys {
            // Only consider keys that are strictly beneath the base path.
            guard key.hasPrefix(basePath), key != basePath else { continue }

            let remainder = String(key.dropFirst(basePath.count))
            // Strip a leading "/" so that both "/dir/" and "/dir" base paths work.
            let trimmed = remainder.hasPrefix("/") ? String(remainder.dropFirst()) : remainder
            guard !trimmed.isEmpty else { continue }

            // Split on the first "/" to get only the immediate child.
            let components = trimmed.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true)
            guard let first = components.first.map(String.init) else { continue }

            if seen.insert(first).inserted {
                // If there is more than one component, this child is a directory.
                let isDirectory = components.count > 1
                result.append(PathElement(name: first, isDirectory: isDirectory))
            }
        }

        // Sort for deterministic output (important for snapshot / glob tests).
        return result.sorted { $0.name < $1.name }
    }
}

// MARK: - Error type

/// Errors thrown by ``VirtualFileReader``.
public enum VirtualFileReaderError: Error, CustomStringConvertible {
    /// A file path passed to the initializer does not start with `/`.
    case invalidPath(String)

    /// The reader has no file registered under the requested path.
    case fileNotFound(String)

    public var description: String {
        switch self {
        case .invalidPath(let path):
            return "VirtualFileReader: file path must start with '/', but got: \"\(path)\""
        case .fileNotFound(let path):
            return "VirtualFileReader: no file registered for path \"\(path)\""
        }
    }
}
