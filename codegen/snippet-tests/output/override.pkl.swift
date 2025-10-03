// Code generated from Pkl module `override`. DO NOT EDIT.
import PklSwift

public enum override {}

public protocol override_Foo: PklRegisteredType, DynamicallyEquatable, Hashable, Sendable {
    var myProp: String { get }
}

extension override {
    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "override"

        public var foo: any Foo

        public init(foo: any Foo) {
            self.foo = foo
        }

        public static func ==(lhs: Module, rhs: Module) -> Bool {
            lhs.foo.isDynamicallyEqual(to: rhs.foo)
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(foo)
        }

        public init(from decoder: any Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let foo = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "foo"))
                .value as! any Foo
            self = Module(foo: foo)
        }
    }

    public typealias Foo = override_Foo

    public struct Bar: Foo {
        public static let registeredIdentifier: String = "override#Bar"

        public var myProp: String

        public init(myProp: String) {
            self.myProp = myProp
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `override.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> override.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `override.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> override.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}