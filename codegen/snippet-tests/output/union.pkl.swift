// Code generated from Pkl module `union`. DO NOT EDIT.
@preconcurrency import PklSwift

public enum union: Sendable {}

extension union {
    /// City; e.g. where people live
    public enum City: String, CaseIterable, CodingKeyRepresentable, Decodable, Hashable, Sendable {
        case sanFrancisco = "San Francisco"
        case london = "London"
        case 上海 = "上海"
    }

    /// Locale that contains cities and towns
    public enum County: String, CaseIterable, CodingKeyRepresentable, Decodable, Hashable, Sendable {
        case sanFrancisco = "San Francisco"
        case sanMateo = "San Mateo"
        case yolo = "Yolo"
    }

    /// Noodles
    public enum Noodles: String, CaseIterable, CodingKeyRepresentable, Decodable, Hashable, Sendable {
        case 拉面 = "拉面"
        case 刀切面 = "刀切面"
        case 面线 = "面线"
        case 意大利面 = "意大利面"
    }

    public enum AccountDisposition: String, CaseIterable, CodingKeyRepresentable, Decodable, Hashable, Sendable {
        case empty = ""
        case icloud3 = "icloud3"
        case prod = "prod"
        case shared = "shared"
    }

    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "union"

        /// A city
        public var city: City

        /// County
        public var county: County

        /// Noodles
        public var noodle: Noodles

        /// Account disposition
        public var disposition: AccountDisposition

        public init(city: City, county: County, noodle: Noodles, disposition: AccountDisposition) {
            self.city = city
            self.county = county
            self.noodle = noodle
            self.disposition = disposition
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `union.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> union.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `union.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> union.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}