// Code generated from Pkl module `MyModule`. DO NOT EDIT.
import PklSwift

public enum MyModule {}

public protocol MyModule_Module: PklRegisteredType, DynamicallyEquatable, Hashable {
    var foo: String { get }
}

extension MyModule {
    public typealias Module = MyModule_Module

    public struct ModuleImpl: Module {
        public static let registeredIdentifier: String = "MyModule"

        public var foo: String

        public init(foo: String) {
            self.foo = foo
        }
    }
}