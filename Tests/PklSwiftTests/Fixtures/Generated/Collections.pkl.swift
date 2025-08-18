// Code generated from Pkl module `Collections`. DO NOT EDIT.
import PklSwift

public enum Collections {}

extension Collections {
    public struct Module: PklRegisteredType, Decodable, Hashable, @unchecked Sendable {
        public static let registeredIdentifier: String = "Collections"

        public var res1: [Int]

        public var res2: [Int]

        public var res3: [[Int]]

        public var res4: [[Int]]

        public var res5: [Int: Bool]

        public var res6: [Int: [Int: Bool]]

        public var res7: [Int: Bool]

        public var res8: [Int: [Int: Bool]]

        public var res9: Set<String>

        public var res10: Set<Int8>

        public init(
            res1: [Int],
            res2: [Int],
            res3: [[Int]],
            res4: [[Int]],
            res5: [Int: Bool],
            res6: [Int: [Int: Bool]],
            res7: [Int: Bool],
            res8: [Int: [Int: Bool]],
            res9: Set<String>,
            res10: Set<Int8>
        ) {
            self.res1 = res1
            self.res2 = res2
            self.res3 = res3
            self.res4 = res4
            self.res5 = res5
            self.res6 = res6
            self.res7 = res7
            self.res8 = res8
            self.res9 = res9
            self.res10 = res10
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `Collections.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> Collections.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `Collections.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> Collections.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}