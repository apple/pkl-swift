// Code generated from Pkl module `ExtendingOpenClass`. DO NOT EDIT.
import PklSwift

public enum ExtendingOpenClass {}

public protocol ExtendingOpenClass_MyOpenClass: PklRegisteredType, DynamicallyEquatable, Hashable {
    var myStr: String { get }
}

extension ExtendingOpenClass {
    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "ExtendingOpenClass"

        public var res1: MyClass

        public var res2: MyClass2

        public init(res1: MyClass, res2: MyClass2) {
            self.res1 = res1
            self.res2 = res2
        }
    }

    public struct MyClass: MyOpenClass {
        public static let registeredIdentifier: String = "ExtendingOpenClass#MyClass"

        public var myBoolean: Bool

        public var myStr: String

        public init(myBoolean: Bool, myStr: String) {
            self.myBoolean = myBoolean
            self.myStr = myStr
        }
    }

    public typealias MyOpenClass = ExtendingOpenClass_MyOpenClass

    public struct MyOpenClassImpl: MyOpenClass {
        public static let registeredIdentifier: String = "ExtendingOpenClass#MyOpenClass"

        public var myStr: String

        public init(myStr: String) {
            self.myStr = myStr
        }
    }

    public struct MyClass2: lib3.GoGoGo {
        public static let registeredIdentifier: String = "ExtendingOpenClass#MyClass2"

        public var myBoolean: Bool

        public var duck: String

        public init(myBoolean: Bool, duck: String) {
            self.myBoolean = myBoolean
            self.duck = duck
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `ExtendingOpenClass.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> ExtendingOpenClass.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `ExtendingOpenClass.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> ExtendingOpenClass.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}