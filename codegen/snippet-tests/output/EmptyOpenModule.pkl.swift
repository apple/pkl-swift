// Code generated from Pkl module `EmptyOpenModule`. DO NOT EDIT.
import PklSwift

public enum EmptyOpenModule {}

public protocol EmptyOpenModule_Module: PklRegisteredType, DynamicallyEquatable, Hashable, Sendable {
}

extension EmptyOpenModule {
    public typealias Module = EmptyOpenModule_Module

    public struct ModuleImpl: Module {
        public static let registeredIdentifier: String = "EmptyOpenModule"

        public init() {}
    }
}