// Code generated from Pkl module `pkl.swift.example.Poly`. DO NOT EDIT.
import PklSwift

public enum pkl_swift_example_Poly {}

public protocol pkl_swift_example_Poly_Animal: pkl_swift_lib1_Being {
    var name: String { get }
}

extension pkl_swift_example_Poly {
    public struct Module: PklRegisteredType, Decodable, Hashable, @unchecked Sendable {
        public static let registeredIdentifier: String = "pkl.swift.example.Poly"

        public var beings: [any pkl_swift_lib1.Being]

        public var rex: Dog

        public var moreBeings: [String: any pkl_swift_lib1.Being]

        public init(
            beings: [any pkl_swift_lib1.Being],
            rex: Dog,
            moreBeings: [String: any pkl_swift_lib1.Being]
        ) {
            self.beings = beings
            self.rex = rex
            self.moreBeings = moreBeings
        }

        public static func ==(lhs: Module, rhs: Module) -> Bool {
            arrayEquals(arr1: lhs.beings, arr2: rhs.beings)
            && lhs.rex == rhs.rex
            && mapEquals(map1: lhs.moreBeings, map2: rhs.moreBeings)
        }

        public func hash(into hasher: inout Hasher) {
            for x in self.beings {
                hasher.combine(x)
            }
            hasher.combine(rex)
            for (k, v) in self.moreBeings {
                hasher.combine(k)
                hasher.combine(v)
            }
        }

        public init(from decoder: Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let beings = try dec.decode([PklSwift.PklAny].self, forKey: PklCodingKey(string: "beings"))
                    .map { $0.value as! any pkl_swift_lib1.Being }
            let rex = try dec.decode(Dog.self, forKey: PklCodingKey(string: "rex"))
            let moreBeings = try dec.decode([String: PklSwift.PklAny].self, forKey: PklCodingKey(string: "moreBeings"))
                    .mapValues { $0.value as! any pkl_swift_lib1.Being }
            self = Module(beings: beings, rex: rex, moreBeings: moreBeings)
        }
    }

    public struct Dog: Animal {
        public static let registeredIdentifier: String = "pkl.swift.example.Poly#Dog"

        public var barks: Bool

        public var hates: (any Animal)?

        public var name: String

        public var exists: Bool

        public init(barks: Bool, hates: (any Animal)?, name: String, exists: Bool) {
            self.barks = barks
            self.hates = hates
            self.name = name
            self.exists = exists
        }

        public static func ==(lhs: Dog, rhs: Dog) -> Bool {
            lhs.barks == rhs.barks
            && ((lhs.hates == nil && rhs.hates == nil) || lhs.hates?.isDynamicallyEqual(to: rhs.hates) ?? false)
            && lhs.name == rhs.name
            && lhs.exists == rhs.exists
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(barks)
            if let hates {
                hasher.combine(hates)
            }
            hasher.combine(name)
            hasher.combine(exists)
        }

        public init(from decoder: Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let barks = try dec.decode(Bool.self, forKey: PklCodingKey(string: "barks"))
            let hates = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "hates"))
                    .value as! (any Animal)?
            let name = try dec.decode(String.self, forKey: PklCodingKey(string: "name"))
            let exists = try dec.decode(Bool.self, forKey: PklCodingKey(string: "exists"))
            self = Dog(barks: barks, hates: hates, name: name, exists: exists)
        }
    }

    public typealias Animal = pkl_swift_example_Poly_Animal

    public struct AnimalImpl: Animal {
        public static let registeredIdentifier: String = "pkl.swift.example.Poly#Animal"

        public var name: String

        public var exists: Bool

        public init(name: String, exists: Bool) {
            self.name = name
            self.exists = exists
        }
    }

    public struct Bird: pkl_swift_lib1.Being {
        public static let registeredIdentifier: String = "pkl.swift.example.Poly#Bird"

        public var name: String

        public var flies: Bool

        public var exists: Bool

        public init(name: String, flies: Bool, exists: Bool) {
            self.name = name
            self.flies = flies
            self.exists = exists
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `pkl_swift_example_Poly.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> pkl_swift_example_Poly.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `pkl_swift_example_Poly.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> pkl_swift_example_Poly.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}