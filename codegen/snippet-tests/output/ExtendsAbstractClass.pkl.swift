// Code generated from Pkl module `ExtendsAbstractClass`. DO NOT EDIT.
import PklSwift

public enum ExtendsAbstractClass {}

public protocol ExtendsAbstractClass_A: PklRegisteredType, DynamicallyEquatable, Hashable {
    var b: String { get }
}

extension ExtendsAbstractClass {
    public struct Module: PklRegisteredType, Decodable, Hashable {
        public static var registeredIdentifier: String = "ExtendsAbstractClass"

        public var a: any A

        public init(a: any A) {
            self.a = a
        }

        public static func ==(lhs: Module, rhs: Module) -> Bool {
            lhs.a.isDynamicallyEqual(to: rhs.a)
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(a)
        }

        public init(from decoder: Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let a = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "a"))
                    .value as! any A
            self = Module(a: a)
        }
    }

    public typealias A = ExtendsAbstractClass_A

    public struct B: A {
        public static var registeredIdentifier: String = "ExtendsAbstractClass#B"

        public var c: String

        public var b: String

        public init(c: String, b: String) {
            self.c = c
            self.b = b
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `ExtendsAbstractClass.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> ExtendsAbstractClass.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `ExtendsAbstractClass.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> ExtendsAbstractClass.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}