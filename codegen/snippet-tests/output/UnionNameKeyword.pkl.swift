// Code generated from Pkl module `UnionNameKeyword`. DO NOT EDIT.
import PklSwift

public enum UnionNameKeyword {}

extension UnionNameKeyword {
    public enum `Type`: String, CaseIterable, CodingKeyRepresentable, Decodable, Hashable, Sendable {
        case one = "one"
        case two = "two"
        case three = "three"
    }

    public struct Module: PklRegisteredType, Decodable, Hashable, @unchecked Sendable {
        public static let registeredIdentifier: String = "UnionNameKeyword"

        public var type: `Type`

        public init(type: `Type`) {
            self.type = type
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `UnionNameKeyword.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> UnionNameKeyword.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `UnionNameKeyword.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> UnionNameKeyword.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}