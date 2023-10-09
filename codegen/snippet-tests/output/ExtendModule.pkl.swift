// Code generated from Pkl module `ExtendModule`. DO NOT EDIT.
import PklSwift

public enum ExtendModule {}

extension ExtendModule {
    public struct Module: MyModule.Module {
        public static var registeredIdentifier: String = "ExtendModule"

        public var bar: String

        public var foo: String

        public init(bar: String, foo: String) {
            self.bar = bar
            self.foo = foo
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `ExtendModule.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> ExtendModule.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `ExtendModule.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> ExtendModule.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}