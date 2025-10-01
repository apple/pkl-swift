// Code generated from Pkl module `UnusedClass`. DO NOT EDIT.
import PklSwift

public enum UnusedClass {}

extension UnusedClass {
    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "UnusedClass"

        public var referencedAlias: UnusedClassDefs.ReferencedAlias

        public init(referencedAlias: UnusedClassDefs.ReferencedAlias) {
            self.referencedAlias = referencedAlias
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `UnusedClass.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> UnusedClass.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `UnusedClass.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> UnusedClass.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}