// Code generated from Pkl module `ApiTypes`. DO NOT EDIT.
import PklSwift

public enum ApiTypes {}

extension ApiTypes {
    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "ApiTypes"

        public var res1: PklSwift.Duration

        public var res2: PklSwift.DataSize

        public var stringClass: PklSwift.Class

        public var baseModuleClass: PklSwift.Class

        public var uint8TypeAlias: PklSwift.TypeAlias

        public var fooClass: PklSwift.Class

        public var barTypeAlias: PklSwift.TypeAlias

        public init(
            res1: PklSwift.Duration,
            res2: PklSwift.DataSize,
            stringClass: PklSwift.Class,
            baseModuleClass: PklSwift.Class,
            uint8TypeAlias: PklSwift.TypeAlias,
            fooClass: PklSwift.Class,
            barTypeAlias: PklSwift.TypeAlias
        ) {
            self.res1 = res1
            self.res2 = res2
            self.stringClass = stringClass
            self.baseModuleClass = baseModuleClass
            self.uint8TypeAlias = uint8TypeAlias
            self.fooClass = fooClass
            self.barTypeAlias = barTypeAlias
        }
    }

    public struct Foo: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "ApiTypes#Foo"

        public init() {}
    }

    public typealias Bar = Foo

    /// Load the Pkl module at the given source and evaluate it into `ApiTypes.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> ApiTypes.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `ApiTypes.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> ApiTypes.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}