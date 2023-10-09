// Code generated from Pkl module `UnionTypes`. DO NOT EDIT.
import PklSwift

public enum UnionTypes {}

public protocol UnionTypes_Animal: PklRegisteredType, DynamicallyEquatable, Hashable {
    var name: String { get }
}

extension UnionTypes {
    public enum Fruit: Decodable, Hashable {
        case banana(Banana)
        case grape(Grape)
        case apple(Apple)

        public init(from decoder: Decoder) throws {
            let decoded = try decoder.singleValueContainer().decode(PklSwift.PklAny.self).value
            switch decoded {
            case let decoded as Banana:
                self = Fruit.banana(decoded)
            case let decoded as Grape:
                self = Fruit.grape(decoded)
            case let decoded as Apple:
                self = Fruit.apple(decoded)
            default:
                throw DecodingError.typeMismatch(
                    Fruit.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type Fruit, but got \(String(describing: decoded))"
                    )
                )
            }
        }
    }

    public enum City: String, CaseIterable, Decodable, Hashable {
        case sanFrancisco = "San Francisco"
        case tokyo = "Tokyo"
        case zurich = "Zurich"
        case london = "London"
    }

    public enum ZebraOrDonkey: Decodable, Hashable {
        case zebra(Zebra)
        case donkey(Donkey)

        public init(from decoder: Decoder) throws {
            let decoded = try decoder.singleValueContainer().decode(PklSwift.PklAny.self).value
            switch decoded {
            case let decoded as Zebra:
                self = ZebraOrDonkey.zebra(decoded)
            case let decoded as Donkey:
                self = ZebraOrDonkey.donkey(decoded)
            default:
                throw DecodingError.typeMismatch(
                    ZebraOrDonkey.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type ZebraOrDonkey, but got \(String(describing: decoded))"
                    )
                )
            }
        }
    }

    public enum AnimalOrString: Decodable, Hashable {
        case animal(any Animal)
        case string(String)

        public static func ==(lhs: AnimalOrString, rhs: AnimalOrString) -> Bool {
            switch (lhs, rhs) {
            case let (.animal(a), .animal(b)):
                return a.isDynamicallyEqual(to: b)
            case let (.string(a), .string(b)):
                return a == b
            default:
                return false
            }
        }

        public init(from decoder: Decoder) throws {
            let decoded = try decoder.singleValueContainer().decode(PklSwift.PklAny.self).value
            switch decoded {
            case let decoded as any Animal:
                self = AnimalOrString.animal(decoded)
            case let decoded as String:
                self = AnimalOrString.string(decoded)
            default:
                throw DecodingError.typeMismatch(
                    AnimalOrString.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type AnimalOrString, but got \(String(describing: decoded))"
                    )
                )
            }
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
            case let .animal(value):
                hasher.combine(value)
            case let .string(value):
                hasher.combine(value)
            }
        }
    }

    public struct Module: PklRegisteredType, Decodable, Hashable {
        public static var registeredIdentifier: String = "UnionTypes"

        public var fruit1: Fruit

        public var fruit2: Fruit

        public var fruit3: Fruit

        public var city1: City

        public var city2: City

        public var city3: City

        public var city4: City

        public var animal1: ZebraOrDonkey

        public var animal2: ZebraOrDonkey

        public var animalOrString1: AnimalOrString

        public var animalOrString2: AnimalOrString

        public init(
            fruit1: Fruit,
            fruit2: Fruit,
            fruit3: Fruit,
            city1: City,
            city2: City,
            city3: City,
            city4: City,
            animal1: ZebraOrDonkey,
            animal2: ZebraOrDonkey,
            animalOrString1: AnimalOrString,
            animalOrString2: AnimalOrString
        ) {
            self.fruit1 = fruit1
            self.fruit2 = fruit2
            self.fruit3 = fruit3
            self.city1 = city1
            self.city2 = city2
            self.city3 = city3
            self.city4 = city4
            self.animal1 = animal1
            self.animal2 = animal2
            self.animalOrString1 = animalOrString1
            self.animalOrString2 = animalOrString2
        }
    }

    public struct Banana: PklRegisteredType, Decodable, Hashable {
        public static var registeredIdentifier: String = "UnionTypes#Banana"

        public var isRipe: Bool

        public init(isRipe: Bool) {
            self.isRipe = isRipe
        }
    }

    public struct Grape: PklRegisteredType, Decodable, Hashable {
        public static var registeredIdentifier: String = "UnionTypes#Grape"

        public var isUsedForWine: Bool

        public init(isUsedForWine: Bool) {
            self.isUsedForWine = isUsedForWine
        }
    }

    public struct Apple: PklRegisteredType, Decodable, Hashable {
        public static var registeredIdentifier: String = "UnionTypes#Apple"

        public var isRed: Bool

        public init(isRed: Bool) {
            self.isRed = isRed
        }
    }

    public typealias Animal = UnionTypes_Animal

    public struct Zebra: Animal {
        public static var registeredIdentifier: String = "UnionTypes#Zebra"

        public var name: String

        public init(name: String) {
            self.name = name
        }
    }

    public struct Donkey: Animal {
        public static var registeredIdentifier: String = "UnionTypes#Donkey"

        public var name: String

        public init(name: String) {
            self.name = name
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `UnionTypes.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> UnionTypes.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `UnionTypes.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> UnionTypes.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}