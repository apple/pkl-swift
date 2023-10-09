// Code generated from Pkl module `ExplicitName`. DO NOT EDIT.
import PklSwift

public enum ExplicitlyCoolName {}

extension ExplicitlyCoolName {
    public enum ConfigType: String, CaseIterable, Decodable, Hashable {
        case one = "one"
        case two = "two"
    }

    public struct Module: PklRegisteredType, Decodable, Hashable {
        public static var registeredIdentifier: String = "ExplicitName"

        public var MyCoolProp: SomethingVeryFunny

        public init(MyCoolProp: SomethingVeryFunny) {
            self.MyCoolProp = MyCoolProp
        }

        enum CodingKeys: String, CodingKey {
            case MyCoolProp = "myProp"
        }
    }

    public struct SomethingVeryFunny: PklRegisteredType, Decodable, Hashable {
        public static var registeredIdentifier: String = "ExplicitName#SomethingFunny"

        public init() {}
    }

    /// Load the Pkl module at the given source and evaluate it into `ExplicitlyCoolName.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> ExplicitlyCoolName.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `ExplicitlyCoolName.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> ExplicitlyCoolName.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}