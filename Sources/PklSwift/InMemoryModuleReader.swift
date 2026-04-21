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

/// A ``ModuleReader`` backed by an in-memory dictionary of URI strings → Pkl source text.
///
/// Use this to evaluate virtual multi-file Pkl configurations without touching disk.
/// It is particularly useful for:
/// - **Unit testing**: supply known Pkl text without writing temporary files.
/// - **Dynamic configuration**: assemble Pkl modules from runtime data and evaluate them.
/// - **Multi-file setups**: model `amends`/`import` relationships across several virtual modules.
///
/// ## Example
///
/// ```swift
/// let reader = InMemoryModuleReader([
///     "mem:base.pkl":   "abstract module Base\nhost: String",
///     "mem:config.pkl": #"amends "mem:base.pkl"\nhost = "localhost""#,
/// ])
/// let options = EvaluatorOptions.preconfigured.withModuleReader(reader)
/// try await withEvaluator(options: options) { evaluator in
///     let output = try await evaluator.evaluateOutputText(
///         source: .uri("mem:config.pkl")!
///     )
///     print(output) // host = "localhost"
/// }
/// ```
///
/// ## URI Format
///
/// Keys in the dictionary must be fully-qualified URIs whose scheme matches the reader's
/// ``scheme`` property (default: `"mem"`). For hierarchical URIs the path should begin
/// with a forward slash, e.g. `"mem:/catalog/birds.pkl"`.
/// Non-hierarchical URIs need no slash, e.g. `"mem:config.pkl"`.
///
/// ## Glob and Triple-Dot Imports
///
/// Because ``isGlobbable`` and ``isLocal`` are both `true`, Pkl's `import*(...)` and
/// triple-dot (`...`) import syntax both work against the registered modules.
/// ``listElements(uri:)`` returns the *direct* children of the given base URI,
/// sorted alphabetically for deterministic output.
public struct InMemoryModuleReader: ModuleReader {
    // MARK: - Stored properties

    /// The URI-keyed dictionary of Pkl source strings this reader serves.
    ///
    /// Keys are fully-qualified URI strings (e.g. `"mem:config.pkl"` or
    /// `"mem:/catalog/swallow.pkl"`). Values are the raw Pkl source text.
    public let modules: [String: String]

    /// The URI scheme handled by this reader.
    ///
    /// Defaults to `"mem"`. Override if you need multiple independent readers
    /// in the same evaluator, or if `"mem"` conflicts with another reader.
    public let scheme: String

    // MARK: - Initializer

    /// Creates an ``InMemoryModuleReader`` from a dictionary of URI → Pkl source mappings.
    ///
    /// - Parameters:
    ///   - modules: A dictionary whose keys are fully-qualified URI strings and whose values
    ///              are the Pkl source text for that module.
    ///   - scheme:  The URI scheme this reader claims. Defaults to `"mem"`.
    public init(_ modules: [String: String], scheme: String = "mem") {
        self.modules = modules
        self.scheme = scheme
    }

    // MARK: - ModuleReader conformance

    /// `true` — enables `import*(...)` glob syntax against registered modules.
    public var isGlobbable: Bool { true }

    /// `true` — hierarchical path components are meaningful (enables triple-dot imports).
    public var hasHierarchicalUris: Bool { true }

    /// `true` — Pkl treats these modules as local, enabling triple-dot (`...`) resolution.
    public var isLocal: Bool { true }

    /// Returns the Pkl source text for the module at `url`.
    ///
    /// - Throws: ``InMemoryModuleReaderError/moduleNotFound(_:)`` when no module is
    ///   registered under `url.absoluteString`.
    public func read(url: URL) async throws -> String {
        let key = url.absoluteString
        guard let source = modules[key] else {
            throw InMemoryModuleReaderError.moduleNotFound(key)
        }
        return source
    }

    /// Returns the direct children of `uri` among all registered module keys.
    ///
    /// The implementation performs a single linear scan of ``modules``, strips the
    /// common `uri` prefix, and groups results by their first remaining path component.
    /// Directory entries (intermediate path segments) are synthesised automatically.
    /// Output is sorted by name for deterministic glob results.
    public func listElements(uri: URL) async throws -> [PathElement] {
        let base = uri.absoluteString
        var seen = Set<String>()
        var result: [PathElement] = []

        for key in modules.keys {
            // Only consider keys that are strictly beneath the base URI.
            guard key.hasPrefix(base), key != base else { continue }

            let remainder = String(key.dropFirst(base.count))
            // Strip a leading "/" so that both "mem:/dir/f.pkl" and "mem:dir/f.pkl" work.
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

/// Errors thrown by ``InMemoryModuleReader``.
public enum InMemoryModuleReaderError: Error, CustomStringConvertible {
    /// The reader has no module registered under the requested URI.
    case moduleNotFound(String)

    public var description: String {
        switch self {
        case .moduleNotFound(let uri):
            return "InMemoryModuleReader: no module registered for URI \"\(uri)\""
        }
    }
}
