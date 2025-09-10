// Code generated from Pkl module `ApiTypes`. DO NOT EDIT.
import PklSwift

public enum ApiTypes {}

extension ApiTypes {
    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "ApiTypes"

        public var dur: Duration

        public var data: DataSize

        public var pair1: Pair<AnyHashable?, AnyHashable?>

        public var pair2: Pair<String, Int>

        public var pair3: Pair<String, Int?>

        public var pair4: Pair<String, Int?>

        public var pairListing1: [Pair<AnyHashable?, AnyHashable?>]

        public var pairListing2: [Pair<String, Int?>]

        public var regex: PklRegex

        public var seq: IntSeq

        public init(
            dur: Duration,
            data: DataSize,
            pair1: Pair<AnyHashable?, AnyHashable?>,
            pair2: Pair<String, Int>,
            pair3: Pair<String, Int?>,
            pair4: Pair<String, Int?>,
            pairListing1: [Pair<AnyHashable?, AnyHashable?>],
            pairListing2: [Pair<String, Int?>],
            regex: PklRegex,
            seq: IntSeq
        ) {
            self.dur = dur
            self.data = data
            self.pair1 = pair1
            self.pair2 = pair2
            self.pair3 = pair3
            self.pair4 = pair4
            self.pairListing1 = pairListing1
            self.pairListing2 = pairListing2
            self.regex = regex
            self.seq = seq
        }
    }

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