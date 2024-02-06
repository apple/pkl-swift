// Code generated from Pkl module `Classes`. DO NOT EDIT.
import PklSwift

public enum Classes {}

public protocol Classes_Animal: PklRegisteredType, DynamicallyEquatable, Hashable {
    var name: String { get }
}

extension Classes {
    public struct Module: PklRegisteredType, Decodable, Hashable {
        public static let registeredIdentifier: String = "Classes"

        public var animals: [any Animal]

        public init(animals: [any Animal]) {
            self.animals = animals
        }

        public static func ==(lhs: Module, rhs: Module) -> Bool {
            arrayEquals(arr1: lhs.animals, arr2: rhs.animals)
        }

        public func hash(into hasher: inout Hasher) {
            for x in self.animals {
                hasher.combine(x)
            }
        }

        public init(from decoder: Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let animals = try dec.decode([PklSwift.PklAny].self, forKey: PklCodingKey(string: "animals"))
                    .map { $0.value as! any Animal }
            self = Module(animals: animals)
        }
    }

    public typealias Animal = Classes_Animal

    public struct AnimalImpl: Animal {
        public static let registeredIdentifier: String = "Classes#Animal"

        public var name: String

        public init(name: String) {
            self.name = name
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `Classes.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> Classes.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `Classes.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> Classes.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}