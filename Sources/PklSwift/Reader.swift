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

public protocol BaseReader {
    /// The scheme part of the URL that this reader can read.
    var scheme: String { get }

    /// Tells if this reader supports Pkl's `import*` and `glob*` keywords.
    var isGlobbable: Bool { get }

    /// Tells if the URIs handled by this reader are hierarchical.
    /// Hierarchical URIs are URIs that have hierarchy elements like host, origin, query, and
    /// fragment.
    ///
    /// A hierarchical URI must start with a "/" in its scheme specific part. For example, consider
    /// the following two URIS:
    ///
    /// ```
    /// birds:/catalog/swallow.pkl
    /// birds:catalog/swallow.pkl
    /// ```
    ///
    /// The first URI conveys name "swallow.pkl" within parent "/catalog/". The second URI
    /// conveys the name "catalog/swallow.pkl" with no hierarchical meaning.
    var hasHierarchicalUris: Bool { get }

    /// Returns elements at a specified path.
    /// If ``BaseReader.hasHierarchicalUris`` is `false`, the uri parameter will be a dummy value,
    /// and this method should return all possible values.
    func listElements(uri: URL) async throws -> [PathElement]
}

/// A custom module reader for Pkl.
///
/// A ``ModuleReader`` registers the scheme that it is responsible for reading via the `scheme` property.
/// For example, a module reader can declare that it reads a resource at `myscheme:/myFile.pkl` by setting its `scheme`
/// to `"myscheme"`.
///
/// Modules are cached by Pkl for the lifetime of an ``Evaluator``. Therefore, cacheing is not needed
/// on the Pkl side as long as the same Evaluator is used.
///
/// Modules are read in Pkl via the import declaration:
///
/// ```
///	import "myscheme:/myFile.pkl"
///	import* "myscheme:/*.pkl" // only when the reader is globbable
/// ```
///
/// Or via the import expression:
///
/// ```
///	import("myscheme:/myFile.pkl")
///	import*("myscheme:/myFile.pkl") // only when the reader is globbable
/// ```
///
/// To provide a custom reader, register it with ``EvaluatorOptions.withModuleReader(_:ModuleReader)``
public protocol ModuleReader: BaseReader {
    /// Tells if the resources handled by this reader are local to the file system.
    ///
    /// A local resource means that triple-dot import syntax will be resolved.
    /// It is expected that I/O operations for this resource to be fast.
    var isLocal: Bool { get }

    /// Read the module at the provided URL, and return its contents as a string.
    func read(url: URL) async throws -> String
}

extension ModuleReader {
    func toMessage() -> ModuleReaderSpec {
        .init(scheme: scheme, hasHierarchicalUris: hasHierarchicalUris, isLocal: isLocal, isGlobbable: isGlobbable)
    }
}

public protocol ResourceReader: BaseReader {
    /// Reads resources from the provided URL into a byte array.
    func read(url: URL) async throws -> [UInt8]
}

extension ResourceReader {
    func toMessage() -> ResourceReaderSpec {
        .init(scheme: scheme, hasHierarchicalUris: hasHierarchicalUris, isGlobbable: isGlobbable)
    }
}

/// An element within a base URI.
///
/// For example, a ``PathElement`` with name `bar.txt` and is not a directory at base URI `file:////foo/`
/// implies URI resource `file:///foo/bar.txt`.
public struct PathElement {
    /// The name of the path element
    public let name: String

    /// Whether the element is a directory or not.
    public let isDirectory: Bool

    public init(name: String, isDirectory: Bool) {
        self.name = name
        self.isDirectory = isDirectory
    }
}

extension PathElement {
    func toMessage() -> PathElementMessage {
        .init(name: self.name, isDirectory: self.isDirectory)
    }
}
