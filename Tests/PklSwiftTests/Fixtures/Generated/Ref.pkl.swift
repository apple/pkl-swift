// Code generated from Pkl module `Ref`. DO NOT EDIT.
import PklSwift

public enum Ref {}

extension Ref {
    public enum MapKeyValue: Decodable, Hashable, Sendable {
        case string(String)
        case int(Int)

        private static func decodeNumeric(from decoder: any Decoder, _ container: any SingleValueDecodingContainer) -> MapKeyValue? {
            return try? .int(container.decode(Int.self))
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let decoded = MapKeyValue.decodeNumeric(from: decoder, container)
            if decoded != nil {
                self = decoded!
                return
            }
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as String:
                self = MapKeyValue.string(decoded)
            default:
                throw DecodingError.typeMismatch(
                    MapKeyValue.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type MapKeyValue, but got \(String(describing: value))"
                    )
                )
            }
        }
    }

    public struct Module: PklRegisteredType, Decodable, Hashable, @unchecked Sendable {
        public static let registeredIdentifier: String = "Ref"

        public var res0: Reference<D>

        public var res1: Reference<D>

        public var res2: Reference<D>

        public var res3: Reference<D>

        public var res4: Reference<D>

        public var res5: AnyHashable?

        public init(
            res0: Reference<D>,
            res1: Reference<D>,
            res2: Reference<D>,
            res3: Reference<D>,
            res4: Reference<D>,
            res5: AnyHashable?
        ) {
            self.res0 = res0
            self.res1 = res1
            self.res2 = res2
            self.res3 = res3
            self.res4 = res4
            self.res5 = res5
        }

        public init(from decoder: any Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let res0 = try dec.decode(Reference<D>.self, forKey: PklCodingKey(string: "res0"))
            let res1 = try dec.decode(Reference<D>.self, forKey: PklCodingKey(string: "res1"))
            let res2 = try dec.decode(Reference<D>.self, forKey: PklCodingKey(string: "res2"))
            let res3 = try dec.decode(Reference<D>.self, forKey: PklCodingKey(string: "res3"))
            let res4 = try dec.decode(Reference<D>.self, forKey: PklCodingKey(string: "res4"))
            let res5 = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "res5"))
                .value
            self = Module(res0: res0, res1: res1, res2: res2, res3: res3, res4: res4, res5: res5)
        }
    }

    public struct D: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "Ref#D"

        public init() {}
    }

    public struct A: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "Ref#A"

        public var foo: Int

        public var bar: [PklSwift.OptionalDictionaryKey<String>: Int]

        public var baz: [MapKey: String]

        public init(
            foo: Int,
            bar: [PklSwift.OptionalDictionaryKey<String>: Int],
            baz: [MapKey: String]
        ) {
            self.foo = foo
            self.bar = bar
            self.baz = baz
        }
    }

    public struct MapKey: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "Ref#MapKey"

        public var key: MapKeyValue

        public init(key: MapKeyValue) {
            self.key = key
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `Ref.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> Ref.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `Ref.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> Ref.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}