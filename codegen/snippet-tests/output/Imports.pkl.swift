// Code generated from Pkl module `Imports`. DO NOT EDIT.
import PklSwift

public enum Imports {}

extension Imports {
    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "Imports"

        public var foo: Foo.Module

        public init(foo: Foo.Module) {
            self.foo = foo
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `Imports.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> Imports.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `Imports.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> Imports.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}