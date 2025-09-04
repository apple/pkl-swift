// Code generated from Pkl module `NoCollectThroughHidden`. DO NOT EDIT.
import PklSwift

public enum NoCollectThroughHidden {}

extension NoCollectThroughHidden {
    public struct Module: PklRegisteredType, Decodable, Hashable {
        public static let registeredIdentifier: String = "NoCollectThroughHidden"

        public init() {}
    }

    /// Load the Pkl module at the given source and evaluate it into `NoCollectThroughHidden.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> NoCollectThroughHidden.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `NoCollectThroughHidden.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> NoCollectThroughHidden.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}