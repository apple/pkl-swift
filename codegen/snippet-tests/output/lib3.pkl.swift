// Code generated from Pkl module `lib3`. DO NOT EDIT.
import PklSwift

public enum lib3 {}

public protocol lib3_GoGoGo: PklRegisteredType, DynamicallyEquatable, Hashable {
    var duck: String { get }
}

extension lib3 {
    public typealias GoGoGo = lib3_GoGoGo

    public struct GoGoGoImpl: GoGoGo {
        public static let registeredIdentifier: String = "lib3#GoGoGo"

        public var duck: String

        public init(duck: String) {
            self.duck = duck
        }
    }

    public struct Module: PklRegisteredType, Decodable, Hashable {
        public static let registeredIdentifier: String = "lib3"

        public init() {}
    }

    /// Load the Pkl module at the given source and evaluate it into `lib3.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> lib3.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `lib3.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> lib3.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}