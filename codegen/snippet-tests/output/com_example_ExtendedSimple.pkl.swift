// Code generated from Pkl module `com.example.ExtendedSimple`. DO NOT EDIT.
import PklSwift

public enum com_example_ExtendedSimple {}

extension com_example_ExtendedSimple {
    public struct Module: PklRegisteredType, Decodable, Hashable {
        public static let registeredIdentifier: String = "com.example.ExtendedSimple"

        public init() {}
    }

    public struct ExtendedSimple: com_example_Simple.Person {
        public static let registeredIdentifier: String = "com.example.ExtendedSimple#ExtendedSimple"

        public var eyeColor: String

        /// The name of the person
        public var theName: String

        /// Some name that matches a keyword
        public var `enum`: String

        public init(eyeColor: String, theName: String, `enum`: String) {
            self.eyeColor = eyeColor
            self.theName = theName
            self.`enum` = `enum`
        }

        enum CodingKeys: String, CodingKey {
            case eyeColor = "eyeColor"
            case theName = "the name"
            case `enum` = "enum"
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `com_example_ExtendedSimple.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> com_example_ExtendedSimple.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `com_example_ExtendedSimple.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> com_example_ExtendedSimple.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}