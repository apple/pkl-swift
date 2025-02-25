// Code generated from Pkl module `Enums`. DO NOT EDIT.
import PklSwift

public enum Enums {}

extension Enums {
    /// City is one of these four fantastic cities
    public enum City: String, CaseIterable, CodingKeyRepresentable, Decodable, Hashable {
        case sanFrancisco = "San Francisco"
        case london = "London"
        case zurich = "Zurich"
        case cupertino = "Cupertino"
    }

    /// Animal is either a horse, monkey, or zebra
    public enum Animal: Decodable, Hashable {
        case horse(Horse)
        case zebra(Zebra)
        case monkey(Monkey)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as Horse:
                self = Animal.horse(decoded)
            case let decoded as Zebra:
                self = Animal.zebra(decoded)
            case let decoded as Monkey:
                self = Animal.monkey(decoded)
            default:
                throw DecodingError.typeMismatch(
                    Animal.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type Animal, but got \(String(describing: value))"
                    )
                )
            }
        }
    }

    /// Either a dictionary or an array.
    public enum DictOrArray: Decodable, Hashable {
        case dictionaryStringString([String: String])
        case arrayString([String])

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as [String: String]:
                self = DictOrArray.dictionaryStringString(decoded)
            case let decoded as [String]:
                self = DictOrArray.arrayString(decoded)
            default:
                throw DecodingError.typeMismatch(
                    DictOrArray.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type DictOrArray, but got \(String(describing: value))"
                    )
                )
            }
        }
    }

    public enum HorseOrBug: Decodable, Hashable {
        case horse(Horse)
        case string(String)
        case string(String)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as Horse:
                self = HorseOrBug.horse(decoded)
            case let decoded as String:
                self = HorseOrBug.string(decoded)
            case let decoded as String:
                self = HorseOrBug.string(decoded)
            default:
                throw DecodingError.typeMismatch(
                    HorseOrBug.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type HorseOrBug, but got \(String(describing: value))"
                    )
                )
            }
        }
    }

    public enum MaybeHorseOrDefinitelyZebra: Decodable, Hashable {
        case horse(Horse?)
        case zebra(Zebra)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as Horse?:
                self = MaybeHorseOrDefinitelyZebra.horse(decoded)
            case let decoded as Zebra:
                self = MaybeHorseOrDefinitelyZebra.zebra(decoded)
            default:
                throw DecodingError.typeMismatch(
                    MaybeHorseOrDefinitelyZebra.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type MaybeHorseOrDefinitelyZebra, but got \(String(describing: value))"
                    )
                )
            }
        }
    }

    public struct Module: PklRegisteredType, Decodable, Hashable {
        public static let registeredIdentifier: String = "Enums"

        /// City of tomorrow!
        public var city: City

        /// The animal
        public var animal: Animal

        /// Some dictionary or array type.
        public var dictOrArray: DictOrArray

        /// Bugs are cool.
        public var bug: BugBug

        public var horseOrBug: HorseOrBug

        public init(
            city: City,
            animal: Animal,
            dictOrArray: DictOrArray,
            bug: BugBug,
            horseOrBug: HorseOrBug
        ) {
            self.city = city
            self.animal = animal
            self.dictOrArray = dictOrArray
            self.bug = bug
            self.horseOrBug = horseOrBug
        }
    }

    public struct Horse: PklRegisteredType, Decodable, Hashable {
        public static let registeredIdentifier: String = "Enums#Horse"

        public var neigh: Bool

        public init(neigh: Bool) {
            self.neigh = neigh
        }
    }

    public struct Zebra: PklRegisteredType, Decodable, Hashable {
        public static let registeredIdentifier: String = "Enums#Zebra"

        public var stripes: String

        public init(stripes: String) {
            self.stripes = stripes
        }
    }

    public struct Monkey: PklRegisteredType, Decodable, Hashable {
        public static let registeredIdentifier: String = "Enums#Monkey"

        public var tail: String

        public init(tail: String) {
            self.tail = tail
        }
    }

    public typealias BugBug = String

    /// Load the Pkl module at the given source and evaluate it into `Enums.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> Enums.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `Enums.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> Enums.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}