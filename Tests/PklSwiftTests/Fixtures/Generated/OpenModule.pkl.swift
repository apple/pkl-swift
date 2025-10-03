// Code generated from Pkl module `OpenModule`. DO NOT EDIT.
import PklSwift

public enum OpenModule {}

public protocol OpenModule_Module: PklRegisteredType, DynamicallyEquatable, Hashable, Sendable {
    var foo: String { get }

    var bar: Int { get }
}

extension OpenModule {
    public typealias Module = OpenModule_Module

    public struct ModuleImpl: Module {
        public static let registeredIdentifier: String = "OpenModule"

        public var foo: String

        public var bar: Int

        public init(foo: String, bar: Int) {
            self.foo = foo
            self.bar = bar
        }
    }
}