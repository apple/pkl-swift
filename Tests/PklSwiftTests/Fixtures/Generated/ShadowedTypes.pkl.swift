// Code generated from Pkl module `ShadowedTypes`. DO NOT EDIT.
import PklSwift

public enum ShadowedTypes {}

extension ShadowedTypes {
    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "ShadowedTypes"

        public var alias: TypeAlias

        public init(alias: TypeAlias) {
            self.alias = alias
        }
    }

    public struct TypeAlias: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "ShadowedTypes#Alias"

        public var value: PklSwift.TypeAlias

        public var values: [PklSwift.TypeAlias]

        public init(value: PklSwift.TypeAlias, values: [PklSwift.TypeAlias]) {
            self.value = value
            self.values = values
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `ShadowedTypes.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> ShadowedTypes.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `ShadowedTypes.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> ShadowedTypes.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}