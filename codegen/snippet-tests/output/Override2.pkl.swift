// Code generated from Pkl module `Override2`. DO NOT EDIT.
import PklSwift

public enum Override2 {}

public protocol Override2_Module: PklRegisteredType, DynamicallyEquatable, Hashable, Sendable {
    var foo: String { get }
}

extension Override2 {
    public typealias Module = Override2_Module

    public struct ModuleImpl: Module {
        public static let registeredIdentifier: String = "Override2"

        /// Doc comments
        public var foo: String

        public init(foo: String) {
            self.foo = foo
        }
    }

    public struct MySubclass: Module {
        public static let registeredIdentifier: String = "Override2#MySubclass"

        /// Doc comments
        public var foo: String

        public init(foo: String) {
            self.foo = foo
        }
    }
}