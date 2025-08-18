// Code generated from Pkl module `Foo`. DO NOT EDIT.
import PklSwift

public enum Foo {}

public protocol Foo_Animal: Foo_Being {
    var name: String { get }
}

public protocol Foo_Being: PklRegisteredType, DynamicallyEquatable, Hashable {
    var exists: Bool { get }
}

extension Foo {
    public struct Module: PklRegisteredType, Decodable, Hashable, @unchecked Sendable {
        public static let registeredIdentifier: String = "Foo"

        public var animals: [any Animal]

        public init(animals: [any Animal]) {
            self.animals = animals
        }

        public static func ==(lhs: Module, rhs: Module) -> Bool {
            arrayEquals(arr1: lhs.animals, arr2: rhs.animals)
        }

        public func hash(into hasher: inout Hasher) {
            for x in self.animals {
                hasher.combine(x)
            }
        }

        public init(from decoder: Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let animals = try dec.decode([PklSwift.PklAny].self, forKey: PklCodingKey(string: "animals"))
                    .map { $0.value as! any Animal }
            self = Module(animals: animals)
        }
    }

    public typealias Animal = Foo_Animal

    public struct AnimalImpl: Animal {
        public static let registeredIdentifier: String = "Foo#Animal"

        public var name: String

        public var exists: Bool

        public init(name: String, exists: Bool) {
            self.name = name
            self.exists = exists
        }
    }

    public typealias Being = Foo_Being

    public struct Bird: Animal {
        public static let registeredIdentifier: String = "Foo#Bird"

        public var flies: Bool

        public var name: String

        public var exists: Bool

        public init(flies: Bool, name: String, exists: Bool) {
            self.flies = flies
            self.name = name
            self.exists = exists
        }
    }

    public struct Dog: Animal {
        public static let registeredIdentifier: String = "Foo#Dog"

        public var barks: Bool

        public var name: String

        public var exists: Bool

        public init(barks: Bool, name: String, exists: Bool) {
            self.barks = barks
            self.name = name
            self.exists = exists
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `Foo.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> Foo.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `Foo.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> Foo.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}