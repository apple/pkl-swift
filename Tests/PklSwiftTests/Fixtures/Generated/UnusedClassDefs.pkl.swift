// Code generated from Pkl module `UnusedClassDefs`. DO NOT EDIT.
import PklSwift

public enum UnusedClassDefs {}

extension UnusedClassDefs {
    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "UnusedClassDefs"

        public init() {}
    }

    public struct ThisClassShouldAlsoGenerate: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "UnusedClassDefs#ThisClassShouldAlsoGenerate"

        public init() {}
    }

    public typealias ReferencedAlias = String

    /// Load the Pkl module at the given source and evaluate it into `UnusedClassDefs.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> UnusedClassDefs.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `UnusedClassDefs.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> UnusedClassDefs.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}