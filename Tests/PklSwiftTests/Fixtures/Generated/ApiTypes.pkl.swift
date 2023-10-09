// Code generated from Pkl module `ApiTypes`. DO NOT EDIT.
import PklSwift

public enum ApiTypes {}

extension ApiTypes {
    public struct Module: PklRegisteredType, Decodable, Hashable {
        public static var registeredIdentifier: String = "ApiTypes"

        public var res1: Pair<Int, String>

        public var res2: Duration

        public var res3: DataSize

        public init(res1: Pair<Int, String>, res2: Duration, res3: DataSize) {
            self.res1 = res1
            self.res2 = res2
            self.res3 = res3
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `ApiTypes.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> ApiTypes.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `ApiTypes.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> ApiTypes.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}