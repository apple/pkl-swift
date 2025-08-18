// Code generated from Pkl module `AnyType`. DO NOT EDIT.
import PklSwift

public enum AnyType {}

extension AnyType {
    public struct Module: PklRegisteredType, Decodable, Hashable, @unchecked Sendable {
        public static let registeredIdentifier: String = "AnyType"

        public var bird: AnyHashable?

        public var primitive: AnyHashable?

        public var primitive2: AnyHashable?

        public var array: AnyHashable?

        public var set: AnyHashable?

        public var mapping: AnyHashable?

        public var nullable: AnyHashable?

        public var duration: AnyHashable?

        public var dataSize: AnyHashable?

        public init(
            bird: AnyHashable?,
            primitive: AnyHashable?,
            primitive2: AnyHashable?,
            array: AnyHashable?,
            set: AnyHashable?,
            mapping: AnyHashable?,
            nullable: AnyHashable?,
            duration: AnyHashable?,
            dataSize: AnyHashable?
        ) {
            self.bird = bird
            self.primitive = primitive
            self.primitive2 = primitive2
            self.array = array
            self.set = set
            self.mapping = mapping
            self.nullable = nullable
            self.duration = duration
            self.dataSize = dataSize
        }

        public init(from decoder: Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let bird = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "bird")).value
            let primitive = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "primitive")).value
            let primitive2 = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "primitive2")).value
            let array = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "array")).value
            let set = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "set")).value
            let mapping = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "mapping")).value
            let nullable = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "nullable")).value
            let duration = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "duration")).value
            let dataSize = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "dataSize")).value
            self = Module(bird: bird, primitive: primitive, primitive2: primitive2, array: array, set: set, mapping: mapping, nullable: nullable, duration: duration, dataSize: dataSize)
        }
    }

    public struct Bird: PklRegisteredType, Decodable, Hashable, @unchecked Sendable {
        public static let registeredIdentifier: String = "AnyType#Bird"

        public var species: String

        public init(species: String) {
            self.species = species
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `AnyType.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> AnyType.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `AnyType.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> AnyType.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}