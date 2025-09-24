// Code generated from Pkl module `Classes`. DO NOT EDIT.
import PklSwift

public enum Classes {}

public protocol Classes_Person: Classes_Being {
    var bike: Classes.Bike { get }

    var firstName: UInt16? { get }

    var lastName: [String: UInt32?] { get }

    var things: Set<Int> { get }
}

public protocol Classes_Being: PklRegisteredType, DynamicallyEquatable, Hashable {
    var isAlive: Bool { get }
}

public protocol Classes_C: Classes_B {
    var c: String { get }
}

public protocol Classes_B: Classes_A {
    var b: String { get }
}

public protocol Classes_A: PklRegisteredType, DynamicallyEquatable, Hashable {
    var a: String { get }
}

extension Classes {
    public enum BugKind: String, CaseIterable, CodingKeyRepresentable, Decodable, Hashable, Sendable {
        case butterfly = "butterfly"
        case beetle = #"beetle""#
        case beetleOne = "beetle one"
    }

    public enum BugKindTwo: String, CaseIterable, CodingKeyRepresentable, Decodable, Hashable, Sendable {
        case butterfly = "butterfly"
        case beetle = #"beetle""#
        case beetleOne = "beetle one"
    }

    public enum BugKindThree: String, CaseIterable, CodingKeyRepresentable, Decodable, Hashable, Sendable {
        case butterfly = "butterfly"
        case beetle = #"beetle""#
        case beetleOne = "beetle one"
        case beetle_one = "beetle_one"
    }

    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "Classes"

        public var bug: Bug

        public var 蚊子: Bug

        public var thisPerson: ThisPerson

        public var d: D

        public init(bug: Bug, 蚊子: Bug, thisPerson: ThisPerson, d: D) {
            self.bug = bug
            self.蚊子 = 蚊子
            self.thisPerson = thisPerson
            self.d = d
        }
    }

    public struct Bug: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "Classes#Bug"

        /// The owner of this bug.
        public var owner: (any Person)?

        /// The age of this bug
        public var age: Int?

        /// How long the bug holds its breath for
        public var holdsBreathFor: Duration

        public var size: DataSize

        public var kind: BugKind

        public var kind2: BugKindTwo

        public var kind3: BugKindThree

        public var kind4: BugKindFour

        public var bagOfStuff: Object

        public var bugClass: Class

        public var bugTypeAlias: TypeAlias

        public init(
            owner: (any Person)?,
            age: Int?,
            holdsBreathFor: Duration,
            size: DataSize,
            kind: BugKind,
            kind2: BugKindTwo,
            kind3: BugKindThree,
            kind4: BugKindFour,
            bagOfStuff: Object,
            bugClass: Class,
            bugTypeAlias: TypeAlias
        ) {
            self.owner = owner
            self.age = age
            self.holdsBreathFor = holdsBreathFor
            self.size = size
            self.kind = kind
            self.kind2 = kind2
            self.kind3 = kind3
            self.kind4 = kind4
            self.bagOfStuff = bagOfStuff
            self.bugClass = bugClass
            self.bugTypeAlias = bugTypeAlias
        }

        public static func ==(lhs: Bug, rhs: Bug) -> Bool {
            lhs.owner == nil && rhs.owner == nil || lhs.owner?.isDynamicallyEqual(to: rhs.owner) ?? false
            && lhs.age == nil && rhs.age == nil || lhs.age == rhs.age
            && lhs.holdsBreathFor == rhs.holdsBreathFor
            && lhs.size == rhs.size
            && lhs.kind == rhs.kind
            && lhs.kind2 == rhs.kind2
            && lhs.kind3 == rhs.kind3
            && lhs.kind4 == rhs.kind4
            && lhs.bagOfStuff == rhs.bagOfStuff
            && lhs.bugClass == rhs.bugClass
            && lhs.bugTypeAlias == rhs.bugTypeAlias
        }

        public func hash(into hasher: inout Hasher) {
            if let owner {
                hasher.combine(owner)
            }
            hasher.combine(age)
            hasher.combine(holdsBreathFor)
            hasher.combine(size)
            hasher.combine(kind)
            hasher.combine(kind2)
            hasher.combine(kind3)
            hasher.combine(kind4)
            hasher.combine(bagOfStuff)
            hasher.combine(bugClass)
            hasher.combine(bugTypeAlias)
        }

        public init(from decoder: Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let owner = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "owner"))
                .value as! (any Person)?
            let age = try dec.decode(Int?.self, forKey: PklCodingKey(string: "age"))
            let holdsBreathFor = try dec.decode(Duration.self, forKey: PklCodingKey(string: "holdsBreathFor"))
            let size = try dec.decode(DataSize.self, forKey: PklCodingKey(string: "size"))
            let kind = try dec.decode(BugKind.self, forKey: PklCodingKey(string: "kind"))
            let kind2 = try dec.decode(BugKindTwo.self, forKey: PklCodingKey(string: "kind2"))
            let kind3 = try dec.decode(BugKindThree.self, forKey: PklCodingKey(string: "kind3"))
            let kind4 = try dec.decode(BugKindFour.self, forKey: PklCodingKey(string: "kind4"))
            let bagOfStuff = try dec.decode(Object.self, forKey: PklCodingKey(string: "bagOfStuff"))
            let bugClass = try dec.decode(Class.self, forKey: PklCodingKey(string: "bugClass"))
            let bugTypeAlias = try dec.decode(TypeAlias.self, forKey: PklCodingKey(string: "bugTypeAlias"))
            self = Bug(owner: owner, age: age, holdsBreathFor: holdsBreathFor, size: size, kind: kind, kind2: kind2, kind3: kind3, kind4: kind4, bagOfStuff: bagOfStuff, bugClass: bugClass, bugTypeAlias: bugTypeAlias)
        }
    }

    public typealias Person = Classes_Person

    /// A Person!
    public struct PersonImpl: Person {
        public static let registeredIdentifier: String = "Classes#Person"

        public var bike: Bike

        /// The person's first name
        public var firstName: UInt16?

        /// The person's last name
        public var lastName: [String: UInt32?]

        public var things: Set<Int>

        public var isAlive: Bool

        public init(
            bike: Bike,
            firstName: UInt16?,
            lastName: [String: UInt32?],
            things: Set<Int>,
            isAlive: Bool
        ) {
            self.bike = bike
            self.firstName = firstName
            self.lastName = lastName
            self.things = things
            self.isAlive = isAlive
        }
    }

    public struct Bike: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "Classes#Bike"

        public var isFixie: Bool

        /// Wheels are the front and back wheels.
        ///
        /// There are typically two of them.
        public var wheels: [Wheel]

        public init(isFixie: Bool, wheels: [Wheel]) {
            self.isFixie = isFixie
            self.wheels = wheels
        }
    }

    public struct Wheel: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "Classes#Wheel"

        public var hasSpokes: Bool

        public init(hasSpokes: Bool) {
            self.hasSpokes = hasSpokes
        }
    }

    public typealias Being = Classes_Being

    public struct ThisPerson: Person {
        public static let registeredIdentifier: String = "Classes#ThisPerson"

        public var myself: ThisPerson

        public var someoneElse: any Person

        public var bike: Bike

        /// The person's first name
        public var firstName: UInt16?

        /// The person's last name
        public var lastName: [String: UInt32?]

        public var things: Set<Int>

        public var isAlive: Bool

        public init(
            myself: ThisPerson,
            someoneElse: any Person,
            bike: Bike,
            firstName: UInt16?,
            lastName: [String: UInt32?],
            things: Set<Int>,
            isAlive: Bool
        ) {
            self.myself = myself
            self.someoneElse = someoneElse
            self.bike = bike
            self.firstName = firstName
            self.lastName = lastName
            self.things = things
            self.isAlive = isAlive
        }

        public static func ==(lhs: ThisPerson, rhs: ThisPerson) -> Bool {
            lhs.myself == rhs.myself
            && lhs.someoneElse.isDynamicallyEqual(to: rhs.someoneElse)
            && lhs.bike == rhs.bike
            && lhs.firstName == nil && rhs.firstName == nil || lhs.firstName == rhs.firstName
            && lhs.lastName == rhs.lastName
            && lhs.things == rhs.things
            && lhs.isAlive == rhs.isAlive
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(myself)
            hasher.combine(someoneElse)
            hasher.combine(bike)
            hasher.combine(firstName)
            hasher.combine(lastName)
            hasher.combine(things)
            hasher.combine(isAlive)
        }

        public init(from decoder: Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let myself = try dec.decode(ThisPerson.self, forKey: PklCodingKey(string: "myself"))
            let someoneElse = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "someoneElse"))
                .value as! any Person
            let bike = try dec.decode(Bike.self, forKey: PklCodingKey(string: "bike"))
            let firstName = try dec.decode(UInt16?.self, forKey: PklCodingKey(string: "firstName"))
            let lastName = try dec.decode([String: UInt32?].self, forKey: PklCodingKey(string: "lastName"))
            let things = try dec.decode(Set<Int>.self, forKey: PklCodingKey(string: "things"))
            let isAlive = try dec.decode(Bool.self, forKey: PklCodingKey(string: "isAlive"))
            self = ThisPerson(myself: myself, someoneElse: someoneElse, bike: bike, firstName: firstName, lastName: lastName, things: things, isAlive: isAlive)
        }
    }

    public struct D: C {
        public static let registeredIdentifier: String = "Classes#D"

        public var d: String

        public var c: String

        public var b: String

        public var a: String

        public init(d: String, c: String, b: String, a: String) {
            self.d = d
            self.c = c
            self.b = b
            self.a = a
        }
    }

    public typealias C = Classes_C

    public struct CImpl: C {
        public static let registeredIdentifier: String = "Classes#C"

        public var c: String

        public var b: String

        public var a: String

        public init(c: String, b: String, a: String) {
            self.c = c
            self.b = b
            self.a = a
        }
    }

    public typealias B = Classes_B

    public struct BImpl: B {
        public static let registeredIdentifier: String = "Classes#B"

        public var b: String

        public var a: String

        public init(b: String, a: String) {
            self.b = b
            self.a = a
        }
    }

    public typealias A = Classes_A

    public typealias BugKindFour = String

    /// Load the Pkl module at the given source and evaluate it into `Classes.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> Classes.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `Classes.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> Classes.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}