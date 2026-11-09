// Code generated from Pkl module `Urls`. DO NOT EDIT.
import Foundation
import PklSwift

public enum Urls {}

extension Urls {
    public enum UrlOrInt: Decodable, Hashable, Sendable {
        case uRL(URL)
        case int(Int)

        private static func decodeNumeric(from decoder: any Decoder, _ container: any SingleValueDecodingContainer) -> UrlOrInt? {
            return try? .int(container.decode(Int.self))
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let decoded = UrlOrInt.decodeNumeric(from: decoder, container)
            if decoded != nil {
                self = decoded!
                return
            }
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as URL:
                self = UrlOrInt.uRL(decoded)
            default:
                throw DecodingError.typeMismatch(
                    UrlOrInt.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type UrlOrInt, but got \(String(describing: value))"
                    )
                )
            }
        }
    }

    public struct Module: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "Urls"

        public var homepage: URL

        public var backup: URL?

        public var mirrors: [URL]

        public var byName: [String: URL]

        public var aliased: UrlAlias

        public var either: UrlOrInt

        public init(
            homepage: URL,
            backup: URL?,
            mirrors: [URL],
            byName: [String: URL],
            aliased: UrlAlias,
            either: UrlOrInt
        ) {
            self.homepage = homepage
            self.backup = backup
            self.mirrors = mirrors
            self.byName = byName
            self.aliased = aliased
            self.either = either
        }
    }

    public typealias UrlAlias = URL

    /// Load the Pkl module at the given source and evaluate it into `Urls.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> Urls.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `Urls.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> Urls.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}