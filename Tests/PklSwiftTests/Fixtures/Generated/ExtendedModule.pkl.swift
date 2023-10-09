// Code generated from Pkl module `ExtendedModule`. DO NOT EDIT.
import PklSwift

public enum ExtendedModule {}

extension ExtendedModule {
    public struct Module: OpenModule.Module {
        public static var registeredIdentifier: String = "ExtendedModule"

        public var foo: String

        public var bar: Int

        public init(foo: String, bar: Int) {
            self.foo = foo
            self.bar = bar
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `ExtendedModule.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> ExtendedModule.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `ExtendedModule.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> ExtendedModule.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}