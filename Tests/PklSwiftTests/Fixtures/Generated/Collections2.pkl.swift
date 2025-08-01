// Code generated from Pkl module `Collections2`. DO NOT EDIT.
import PklSwift

public enum Collections2 {}

extension Collections2 {
    public struct Module: PklRegisteredType, Decodable, Hashable {
        public static let registeredIdentifier: String = "Collections2"

        public var res: [UInt8]

        public init(res: [UInt8]) {
            self.res = res
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `Collections2.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> Collections2.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `Collections2.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> Collections2.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}