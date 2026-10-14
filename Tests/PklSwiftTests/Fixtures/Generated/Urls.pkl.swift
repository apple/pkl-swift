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

    public struct Module: PklRegisteredType, Decodable, Hashable, @unchecked Sendable {
        public static let registeredIdentifier: String = "Urls"

        public var absolute: URL

        public var relative: URL

        public var ipv6: URL

        public var zoneId: URL

        public var nullable: URL?

        public var aliased: AliasedUrl

        public var list: [URL]

        public var mapping: [String: URL]

        public var union: UrlOrInt

        public var any: AnyHashable?

        public init(
            absolute: URL,
            relative: URL,
            ipv6: URL,
            zoneId: URL,
            nullable: URL?,
            aliased: AliasedUrl,
            list: [URL],
            mapping: [String: URL],
            union: UrlOrInt,
            any: AnyHashable?
        ) {
            self.absolute = absolute
            self.relative = relative
            self.ipv6 = ipv6
            self.zoneId = zoneId
            self.nullable = nullable
            self.aliased = aliased
            self.list = list
            self.mapping = mapping
            self.union = union
            self.any = any
        }

        public init(from decoder: any Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let absolute = try dec.decode(URL.self, forKey: PklCodingKey(string: "absolute"))
            let relative = try dec.decode(URL.self, forKey: PklCodingKey(string: "relative"))
            let ipv6 = try dec.decode(URL.self, forKey: PklCodingKey(string: "ipv6"))
            let zoneId = try dec.decode(URL.self, forKey: PklCodingKey(string: "zoneId"))
            let nullable = try dec.decode(URL?.self, forKey: PklCodingKey(string: "nullable"))
            let aliased = try dec.decode(AliasedUrl.self, forKey: PklCodingKey(string: "aliased"))
            let list = try dec.decode([URL].self, forKey: PklCodingKey(string: "list"))
            let mapping = try dec.decode([String: URL].self, forKey: PklCodingKey(string: "mapping"))
            let union = try dec.decode(UrlOrInt.self, forKey: PklCodingKey(string: "union"))
            let any = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "any"))
                .value
            self = Module(absolute: absolute, relative: relative, ipv6: ipv6, zoneId: zoneId, nullable: nullable, aliased: aliased, list: list, mapping: mapping, union: union, any: any)
        }
    }

    public typealias AliasedUrl = URL

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