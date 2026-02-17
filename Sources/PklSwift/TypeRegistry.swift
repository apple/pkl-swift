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

import MessagePack
import PklSwiftInternals

/// Marker protocol that all generated Pkl types should conform to.
///
/// It is used by the TypeRegistry to find the types at runtime, and dynamically form a registry of all known pkl types.
public protocol PklRegisteredType: Decodable, Sendable, CodingKeyRepresentable {
    static var registeredIdentifier: String { get }
}

extension PklRegisteredType {
    public var codingKey: any CodingKey {
        PklCodingKey(string: "<obj:\(Self.self)>")
    }

    public init?(codingKey: some CodingKey) {
        fatalError("cannot initialize \(Self.self) from CodingKey")
    }
}

/// This type registry
struct TypeRegistry {
    // TODO: We could optimize the registry building by filtering types by name
    // We'd then need to use a macro on the declared types though to generate "__🟠$pkl_type__MyType" types that speed up the discovery.
    // private static let _pklTypeTypeNameMagic = "__🟠$pkl_type__"

    typealias DecoderInitializer<T> = (_PklDecoder) throws -> T
    typealias AnyDecoderInitializer = (_PklDecoder) throws -> Any
    struct RegistryEntry {
        let type: Any.Type
        let initializer: AnyDecoderInitializer
    }

    private var mappings: [String: RegistryEntry] = [:]

    init() {}

    mutating func register<T>(identifier: String, _ decode: @escaping @Sendable (_PklDecoder) throws -> T) {
        self.mappings[identifier] = .init(
            type: T.self,
            initializer: { decoder in
                try decode(decoder) as Any
            }
        )
    }

    func has(identifier: String) -> Bool {
        self.mappings[identifier] != nil
    }

    func decode<T>(value: MessagePackValue, identifiedBy identifier: String, as _: T.Type) throws -> T {
        guard let entry = mappings[identifier] else {
            throw TypeRegistryError.unknownIdentifier(identifier)
        }
        let decoder = try _PklDecoder(value: value)
        let instance = try entry.initializer(decoder)

        guard let wellTyped = instance as? T else {
            throw TypeRegistryError.unexpectedType(type(of: instance), expected: T.self)
        }

        return wellTyped
    }

    enum TypeRegistryError: Error {
        case unknownIdentifier(String)
        case unexpectedType(Any.Type, expected: Any.Type)
    }
}

extension TypeRegistry {
    // TODO: this will need some performance work to make it faster, but we can do this after we have functionality complete
    // MUST be called while holding the TypeRegistry.shared lock
    static func _initializeShared() -> TypeRegistry {
        precondition(TypeRegistry._shared == nil, "Can only initialize the registry once")
        TypeRegistry._shared = TypeRegistry()

        pkls_enumerateTypes(
            /* nameFilter: */ nil,
            // If we wanted to do filtering by name, this is the place to do it.
            // { typeName, _ in
            //   // strstr() lets us avoid copying either string before comparing.
            //   return Self._pklTypeTypeNameMagic.withCString { typeNameMagic in
            //     nil != strstr(typeName, typeNameMagic)
            //   }
            // }
            /* typeEnumerator: */ { type, _ in
                if let type = unsafeBitCast(type, to: Any.Type.self) as? any PklRegisteredType.Type {
                    var registry = TypeRegistry._shared!
                    registry.register(identifier: type.registeredIdentifier) { decoder in
                        try type.init(from: decoder)
                    }
                    TypeRegistry._shared = registry
                }
            }, /* context: */ nil
        )

        return TypeRegistry._shared! // definitely initialized by now
    }
}

extension TypeRegistry {
    static let _sharedLock: PklLock = .init()
    nonisolated(unsafe) static var _shared: TypeRegistry?

    public static func get() -> TypeRegistry {
        self._sharedLock.withLock {
            if let _shared {
                return _shared
            } else {
                // first time we're accessing so we need to initialize it
                return TypeRegistry._initializeShared()
            }
        }
    }

    static func _registerTypes(_ types: [any PklRegisteredType.Type]) {
        _sharedLock.withLock {
            precondition(
                _shared == nil,
                "registerPklTypes(_:) must be called before any Pkl modules are loaded"
            )
            var registry = TypeRegistry()
            for t in types {
                registry.register(identifier: t.registeredIdentifier) { decoder in
                    try t.init(from: decoder)
                }
            }
            _shared = registry
        }
    }
}

/// Explicitly registers a set of ``PklRegisteredType`` conformers, bypassing
/// the automatic O(N) type discovery that scans all Swift types in the binary.
///
/// In large binaries, the default type discovery must iterate all Swift types
/// linked into the process to find ``PklRegisteredType`` conformers. For
/// binaries with thousands of types, this can add several seconds of latency on
/// the first Pkl module load.
///
/// Call this once, before any `loadFrom` call:
///
/// ```swift
/// registerPklTypes([
///     MyModule.ModuleImpl.self,
///     AnotherModule.Module.self,
/// ])
/// ```
///
/// - Parameter types: All ``PklRegisteredType`` conformers your app will decode.
///   Any Pkl type not included here will result in a decoding error if encountered.
/// - Precondition: Must be called before any Pkl module is loaded.
public func registerPklTypes(_ types: [any PklRegisteredType.Type]) {
    TypeRegistry._registerTypes(types)
}
