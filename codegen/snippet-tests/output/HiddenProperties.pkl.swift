// Code generated from Pkl module `HiddenProperties`. DO NOT EDIT.
import PklSwift

public enum HiddenProperties {}

extension HiddenProperties {
    public struct Module: PklRegisteredType, Decodable, Hashable {
        public static let registeredIdentifier: String = "HiddenProperties"

        public var propC: String

        public init(propC: String) {
            self.propC = propC
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `HiddenProperties.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> HiddenProperties.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `HiddenProperties.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> HiddenProperties.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}