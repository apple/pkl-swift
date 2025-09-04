// Code generated from Pkl module `Pairs`. DO NOT EDIT.
import PklSwift

public enum Pairs {}

extension Pairs {
    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "Pairs"

        public var untyped: Pair<AnyHashable?, AnyHashable?>

        public var typed: Pair<String, Int>

        public var aliased: MyPair

        public var typeArgAliased: OurPair

        public init(
            untyped: Pair<AnyHashable?, AnyHashable?>,
            typed: Pair<String, Int>,
            aliased: MyPair,
            typeArgAliased: OurPair
        ) {
            self.untyped = untyped
            self.typed = typed
            self.aliased = aliased
            self.typeArgAliased = typeArgAliased
        }
    }

    public typealias MyPair = Pair<String, AnyHashable?>

    public typealias OurPair = Pair<String, Foo>

    public typealias Foo = Int

    /// Load the Pkl module at the given source and evaluate it into `Pairs.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> Pairs.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `Pairs.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> Pairs.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}