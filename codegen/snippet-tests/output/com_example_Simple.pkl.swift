// Code generated from Pkl module `com.example.Simple`. DO NOT EDIT.
import PklSwift

public enum com_example_Simple {}

public protocol com_example_Simple_Person: PklRegisteredType, DynamicallyEquatable, Hashable, Sendable {
    var theName: String { get }

    var `enum`: String { get }
}

public protocol com_example_Simple_OpenClassExtendingOpenClass: PklRegisteredType, DynamicallyEquatable, Hashable, Sendable {
    var someOtherProp: Bool? { get }
}

extension com_example_Simple {
    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "com.example.Simple"

        /// This is truly a person.
        public var person: any Person

        public init(person: any Person) {
            self.person = person
        }

        public static func ==(lhs: Module, rhs: Module) -> Bool {
            lhs.person.isDynamicallyEqual(to: rhs.person)
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(person)
        }

        public init(from decoder: any Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let person = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "person"))
                .value as! any Person
            self = Module(person: person)
        }
    }

    public typealias Person = com_example_Simple_Person

    public struct PersonImpl: Person {
        public static let registeredIdentifier: String = "com.example.Simple#Person"

        /// The name of the person
        public var theName: String

        /// Some name that matches a keyword
        public var `enum`: String

        public init(theName: String, `enum`: String) {
            self.theName = theName
            self.`enum` = `enum`
        }

        enum CodingKeys: String, CodingKey {
            case theName = "the name"
            case `enum` = "enum"
        }
    }

    public struct ThePerson: Person {
        public static let registeredIdentifier: String = "com.example.Simple#ThePerson"

        public var the: String

        /// The name of the person
        public var theName: String

        /// Some name that matches a keyword
        public var `enum`: String

        public init(the: String, theName: String, `enum`: String) {
            self.the = the
            self.theName = theName
            self.`enum` = `enum`
        }

        enum CodingKeys: String, CodingKey {
            case the = "the"
            case theName = "the name"
            case `enum` = "enum"
        }
    }

    public typealias OpenClassExtendingOpenClass = com_example_Simple_OpenClassExtendingOpenClass

    public struct OpenClassExtendingOpenClassImpl: OpenClassExtendingOpenClass {
        public static let registeredIdentifier: String = "com.example.Simple#OpenClassExtendingOpenClass"

        public var someOtherProp: Bool?

        public init(someOtherProp: Bool?) {
            self.someOtherProp = someOtherProp
        }
    }

    public struct ClassWithReallyLongConstructor: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "com.example.Simple#ClassWithReallyLongConstructor"

        public var theProperty1: String

        public var theProperty2: String

        public var theProperty3: String

        public var theProperty4: String

        public var theProperty5: String

        public var theProperty6: String

        public init(
            theProperty1: String,
            theProperty2: String,
            theProperty3: String,
            theProperty4: String,
            theProperty5: String,
            theProperty6: String
        ) {
            self.theProperty1 = theProperty1
            self.theProperty2 = theProperty2
            self.theProperty3 = theProperty3
            self.theProperty4 = theProperty4
            self.theProperty5 = theProperty5
            self.theProperty6 = theProperty6
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `com_example_Simple.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> com_example_Simple.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `com_example_Simple.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> com_example_Simple.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}