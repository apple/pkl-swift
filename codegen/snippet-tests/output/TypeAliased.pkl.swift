// Code generated from Pkl module `TypeAliased`. DO NOT EDIT.
import PklSwift

public enum TypeAliased {}

extension TypeAliased {
    public struct Module: PklRegisteredType, Decodable, Hashable, @unchecked Sendable {
        public static let registeredIdentifier: String = "TypeAliased"

        public var myMap: StringyMap

        public init(myMap: StringyMap) {
            self.myMap = myMap
        }
    }

    public typealias StringyMap = [String: String]

    /// Load the Pkl module at the given source and evaluate it into `TypeAliased.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> TypeAliased.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `TypeAliased.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> TypeAliased.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}