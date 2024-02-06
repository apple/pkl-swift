// Code generated from Pkl module `Classes`. DO NOT EDIT.
import PklSwift

public enum Classes {}

extension Classes {
    public struct Module: PklRegisteredType, Decodable, Hashable {
        public static let registeredIdentifier: String = "Classes"

        public var animals: [Animal]

        public init(animals: [Animal]) {
            self.animals = animals
        }
    }

    public struct Animal: PklRegisteredType, Decodable, Hashable {
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