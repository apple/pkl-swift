// Code generated from Pkl module `pkl.swift.lib1`. DO NOT EDIT.
import PklSwift

public enum pkl_swift_lib1 {}

public protocol pkl_swift_lib1_Being: PklRegisteredType, DynamicallyEquatable, Hashable {
    var exists: Bool { get }
}

extension pkl_swift_lib1 {
    public typealias Being = pkl_swift_lib1_Being

    public struct Module: PklRegisteredType, Decodable, Hashable, @unchecked Sendable {
        public static let registeredIdentifier: String = "pkl.swift.lib1"

        public init() {}
    }

    /// Load the Pkl module at the given source and evaluate it into `pkl_swift_lib1.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> pkl_swift_lib1.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `pkl_swift_lib1.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> pkl_swift_lib1.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}