// Code generated from Pkl module `UnionTypes`. DO NOT EDIT.
import PklSwift

public enum UnionTypes {}

public protocol UnionTypes_Animal: PklRegisteredType, DynamicallyEquatable, Hashable {
    var name: String { get }
}

public protocol UnionTypes_Shape: PklRegisteredType, DynamicallyEquatable, Hashable {
}

extension UnionTypes {
    public enum Fruit: Decodable, Hashable, Sendable {
        case banana(Banana)
        case grape(Grape)
        case apple(Apple)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
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
                        debugDescription: "Expected type Fruit, but got \(String(describing: value))"
                    )
                )
            }
        }
    }

    public enum City: String, CaseIterable, CodingKeyRepresentable, Decodable, Hashable, Sendable {
        case sanFrancisco = "San Francisco"
        case tokyo = "Tokyo"
        case zurich = "Zurich"
        case london = "London"
    }

    public enum ZebraOrDonkey: Decodable, Hashable, Sendable {
        case zebra(Zebra)
        case donkey(Donkey)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as Zebra:
                self = ZebraOrDonkey.zebra(decoded)
            case let decoded as Donkey:
                self = ZebraOrDonkey.donkey(decoded)
            default:
                throw DecodingError.typeMismatch(
                    ZebraOrDonkey.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type ZebraOrDonkey, but got \(String(describing: value))"
                    )
                )
            }
        }
    }

    public enum AnimalOrString: Decodable, Hashable, Sendable {
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
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as any Animal:
                self = AnimalOrString.animal(decoded)
            case let decoded as String:
                self = AnimalOrString.string(decoded)
            default:
                throw DecodingError.typeMismatch(
                    AnimalOrString.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type AnimalOrString, but got \(String(describing: value))"
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

    public enum IntOrFloat: Decodable, Hashable, Sendable {
        case int(Int)
        case float64(Float64)

        private static func decodeNumeric(from decoder: Decoder, _ container: any SingleValueDecodingContainer) -> IntOrFloat? {
            return (try? .int(container.decode(Int.self)))
                ?? (try? .float64(container.decode(Float64.self)))
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let decoded = IntOrFloat.decodeNumeric(from: decoder, container)
            if decoded != nil {
                self = decoded!
                return
            }
            let value = try container.decode(PklSwift.PklAny.self).value
            throw DecodingError.typeMismatch(
                IntOrFloat.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected type IntOrFloat, but got \(String(describing: value))"
                )
            )
        }
    }

    public enum Environment: String, CaseIterable, CodingKeyRepresentable, Decodable, Hashable, Sendable {
        case dev = "dev"
        case prod = "prod"
        case qa = "qa"
    }

    public enum AnimalOrShape: Decodable, Hashable, Sendable {
        case animal(any Animal)
        case shape(any Shape)

        public static func ==(lhs: AnimalOrShape, rhs: AnimalOrShape) -> Bool {
            switch (lhs, rhs) {
            case let (.animal(a), .animal(b)):
                return a.isDynamicallyEqual(to: b)
            case let (.shape(a), .shape(b)):
                return a.isDynamicallyEqual(to: b)
            default:
                return false
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as any Animal:
                self = AnimalOrShape.animal(decoded)
            case let decoded as any Shape:
                self = AnimalOrShape.shape(decoded)
            default:
                throw DecodingError.typeMismatch(
                    AnimalOrShape.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type AnimalOrShape, but got \(String(describing: value))"
                    )
                )
            }
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
            case let .animal(value):
                hasher.combine(value)
            case let .shape(value):
                hasher.combine(value)
            }
        }
    }

    public enum Numbers: Decodable, Hashable, Sendable {
        case int8(Int8)
        case int16(Int16)
        case int32(Int32)
        case int(Int)

        private static func decodeNumeric(from decoder: Decoder, _ container: any SingleValueDecodingContainer) -> Numbers? {
            return (try? .int8(container.decode(Int8.self)))
                ?? (try? .int16(container.decode(Int16.self)))
                ?? (try? .int32(container.decode(Int32.self)))
                ?? (try? .int(container.decode(Int.self)))
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let decoded = Numbers.decodeNumeric(from: decoder, container)
            if decoded != nil {
                self = decoded!
                return
            }
            let value = try container.decode(PklSwift.PklAny.self).value
            throw DecodingError.typeMismatch(
                Numbers.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected type Numbers, but got \(String(describing: value))"
                )
            )
        }
    }

    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "UnionTypes"

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

        public var intOrFloat1: IntOrFloat

        public var intOrFloat2: IntOrFloat

        public var intOrFloat3: IntOrFloat

        public var config: [Environment: String]

        public var animalOrShape1: AnimalOrShape

        public var animalOrShape2: AnimalOrShape

        public var numbers1: Numbers

        public var numbers2: Numbers

        public var numbers3: Numbers

        public var numbers4: Numbers

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
            animalOrString2: AnimalOrString,
            intOrFloat1: IntOrFloat,
            intOrFloat2: IntOrFloat,
            intOrFloat3: IntOrFloat,
            config: [Environment: String],
            animalOrShape1: AnimalOrShape,
            animalOrShape2: AnimalOrShape,
            numbers1: Numbers,
            numbers2: Numbers,
            numbers3: Numbers,
            numbers4: Numbers
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
            self.intOrFloat1 = intOrFloat1
            self.intOrFloat2 = intOrFloat2
            self.intOrFloat3 = intOrFloat3
            self.config = config
            self.animalOrShape1 = animalOrShape1
            self.animalOrShape2 = animalOrShape2
            self.numbers1 = numbers1
            self.numbers2 = numbers2
            self.numbers3 = numbers3
            self.numbers4 = numbers4
        }
    }

    public struct Banana: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "UnionTypes#Banana"

        public var isRipe: Bool

        public init(isRipe: Bool) {
            self.isRipe = isRipe
        }
    }

    public struct Grape: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "UnionTypes#Grape"

        public var isUsedForWine: Bool

        public init(isUsedForWine: Bool) {
            self.isUsedForWine = isUsedForWine
        }
    }

    public struct Apple: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "UnionTypes#Apple"

        public var isRed: Bool

        public init(isRed: Bool) {
            self.isRed = isRed
        }
    }

    public typealias Animal = UnionTypes_Animal

    public typealias Shape = UnionTypes_Shape

    public struct Square: Shape {
        public static let registeredIdentifier: String = "UnionTypes#Square"

        public var corners: Int

        public init(corners: Int) {
            self.corners = corners
        }
    }

    public struct Zebra: Animal {
        public static let registeredIdentifier: String = "UnionTypes#Zebra"

        public var name: String

        public init(name: String) {
            self.name = name
        }
    }

    public struct Donkey: Animal {
        public static let registeredIdentifier: String = "UnionTypes#Donkey"

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