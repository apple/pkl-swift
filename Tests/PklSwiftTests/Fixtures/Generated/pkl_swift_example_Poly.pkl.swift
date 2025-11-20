// Code generated from Pkl module `pkl.swift.example.Poly`. DO NOT EDIT.
import PklSwift

public enum pkl_swift_example_Poly {}

public protocol pkl_swift_example_Poly_Animal: pkl_swift_lib1_Being {
    var name: String { get }
}

extension pkl_swift_example_Poly {
    public enum NestListings: Decodable, Hashable, @unchecked Sendable {
        case listingpkl_swift_lib1Being([any pkl_swift_lib1.Being])
        case optional_Listingpkl_swift_lib1Being([any pkl_swift_lib1.Being]?)
        case listing_Optionalpkl_swift_lib1Being([(any pkl_swift_lib1.Being)?])
        case optional__Listing_Optionalpkl_swift_lib1Being([(any pkl_swift_lib1.Being)?]?)
        case listing__Listing_OptionalAnyHashable([[AnyHashable?]])
        case optional___Listing__Listing_OptionalAnyHashable([[AnyHashable?]]?)
        case listing___Optional__Listing_OptionalAnyHashable([[AnyHashable?]?])
        case optional____Listing___Optional__Listing_OptionalAnyHashable([[AnyHashable?]?]?)

        public static func ==(lhs: NestListings, rhs: NestListings) -> Bool {
            switch (lhs, rhs) {
            case let (.listingpkl_swift_lib1Being(a), .listingpkl_swift_lib1Being(b)):
                return arrayEquals(arr1: a, arr2: b)
            case let (.optional_Listingpkl_swift_lib1Being(a), .optional_Listingpkl_swift_lib1Being(b)):
                return a == nil && b == nil || arrayEquals(arr1: a, arr2: b)
            case let (.listing_Optionalpkl_swift_lib1Being(a), .listing_Optionalpkl_swift_lib1Being(b)):
                return arrayEquals(arr1: a, arr2: b)
            case let (.optional__Listing_Optionalpkl_swift_lib1Being(a), .optional__Listing_Optionalpkl_swift_lib1Being(b)):
                return a == nil && b == nil || arrayEquals(arr1: a, arr2: b)
            case let (.listing__Listing_OptionalAnyHashable(a), .listing__Listing_OptionalAnyHashable(b)):
                return a == b
            case let (.optional___Listing__Listing_OptionalAnyHashable(a), .optional___Listing__Listing_OptionalAnyHashable(b)):
                return a == nil && b == nil || a == b
            case let (.listing___Optional__Listing_OptionalAnyHashable(a), .listing___Optional__Listing_OptionalAnyHashable(b)):
                return a == b
            case let (.optional____Listing___Optional__Listing_OptionalAnyHashable(a), .optional____Listing___Optional__Listing_OptionalAnyHashable(b)):
                return a == nil && b == nil || a == b
            default:
                return false
            }
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as [any pkl_swift_lib1.Being]:
                self = NestListings.listingpkl_swift_lib1Being(decoded)
            case let decoded as [any pkl_swift_lib1.Being]?:
                self = NestListings.optional_Listingpkl_swift_lib1Being(decoded)
            case let decoded as [(any pkl_swift_lib1.Being)?]:
                self = NestListings.listing_Optionalpkl_swift_lib1Being(decoded)
            case let decoded as [(any pkl_swift_lib1.Being)?]?:
                self = NestListings.optional__Listing_Optionalpkl_swift_lib1Being(decoded)
            case let decoded as [[AnyHashable?]]:
                self = NestListings.listing__Listing_OptionalAnyHashable(decoded)
            case let decoded as [[AnyHashable?]]?:
                self = NestListings.optional___Listing__Listing_OptionalAnyHashable(decoded)
            case let decoded as [[AnyHashable?]?]:
                self = NestListings.listing___Optional__Listing_OptionalAnyHashable(decoded)
            case let decoded as [[AnyHashable?]?]?:
                self = NestListings.optional____Listing___Optional__Listing_OptionalAnyHashable(decoded)
            default:
                throw DecodingError.typeMismatch(
                    NestListings.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type NestListings, but got \(String(describing: value))"
                    )
                )
            }
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
            case let .listingpkl_swift_lib1Being(value):
                hasher.combine("listingpkl_swift_lib1Being")
                for x in value {
                    hasher.combine(x)
                }
            case let .optional_Listingpkl_swift_lib1Being(value):
                hasher.combine("optional_Listingpkl_swift_lib1Being")
                if let value {
                    for x in value {
                        hasher.combine(x)
                    }
                }
            case let .listing_Optionalpkl_swift_lib1Being(value):
                hasher.combine("listing_Optionalpkl_swift_lib1Being")
                for x in value {
                    if let x {
                        hasher.combine(x)
                    }
                }
            case let .optional__Listing_Optionalpkl_swift_lib1Being(value):
                hasher.combine("optional__Listing_Optionalpkl_swift_lib1Being")
                if let value {
                    for x in value {
                        if let x {
                            hasher.combine(x)
                        }
                    }
                }
            case let .listing__Listing_OptionalAnyHashable(value):
                hasher.combine("listing__Listing_OptionalAnyHashable")
                for x in value {
                    for x in x {
                        if let x {
                            hasher.combine(x)
                        }
                    }
                }
            case let .optional___Listing__Listing_OptionalAnyHashable(value):
                hasher.combine("optional___Listing__Listing_OptionalAnyHashable")
                if let value {
                    for x in value {
                        for x in x {
                            if let x {
                                hasher.combine(x)
                            }
                        }
                    }
                }
            case let .listing___Optional__Listing_OptionalAnyHashable(value):
                hasher.combine("listing___Optional__Listing_OptionalAnyHashable")
                for x in value {
                    if let x {
                        for x in x {
                            if let x {
                                hasher.combine(x)
                            }
                        }
                    }
                }
            case let .optional____Listing___Optional__Listing_OptionalAnyHashable(value):
                hasher.combine("optional____Listing___Optional__Listing_OptionalAnyHashable")
                if let value {
                    for x in value {
                        if let x {
                            for x in x {
                                if let x {
                                    hasher.combine(x)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public enum NestLists: Decodable, Hashable, @unchecked Sendable {
        case listpkl_swift_lib1Being([any pkl_swift_lib1.Being])
        case optional_Listpkl_swift_lib1Being([any pkl_swift_lib1.Being]?)
        case list_Optionalpkl_swift_lib1Being([(any pkl_swift_lib1.Being)?])
        case optional__List_Optionalpkl_swift_lib1Being([(any pkl_swift_lib1.Being)?]?)
        case list__List_OptionalAnyHashable([[AnyHashable?]])
        case optional___List__List_OptionalAnyHashable([[AnyHashable?]]?)
        case list___Optional__List_OptionalAnyHashable([[AnyHashable?]?])
        case optional____List___Optional__List_OptionalAnyHashable([[AnyHashable?]?]?)

        public static func ==(lhs: NestLists, rhs: NestLists) -> Bool {
            switch (lhs, rhs) {
            case let (.listpkl_swift_lib1Being(a), .listpkl_swift_lib1Being(b)):
                return arrayEquals(arr1: a, arr2: b)
            case let (.optional_Listpkl_swift_lib1Being(a), .optional_Listpkl_swift_lib1Being(b)):
                return a == nil && b == nil || arrayEquals(arr1: a, arr2: b)
            case let (.list_Optionalpkl_swift_lib1Being(a), .list_Optionalpkl_swift_lib1Being(b)):
                return arrayEquals(arr1: a, arr2: b)
            case let (.optional__List_Optionalpkl_swift_lib1Being(a), .optional__List_Optionalpkl_swift_lib1Being(b)):
                return a == nil && b == nil || arrayEquals(arr1: a, arr2: b)
            case let (.list__List_OptionalAnyHashable(a), .list__List_OptionalAnyHashable(b)):
                return a == b
            case let (.optional___List__List_OptionalAnyHashable(a), .optional___List__List_OptionalAnyHashable(b)):
                return a == nil && b == nil || a == b
            case let (.list___Optional__List_OptionalAnyHashable(a), .list___Optional__List_OptionalAnyHashable(b)):
                return a == b
            case let (.optional____List___Optional__List_OptionalAnyHashable(a), .optional____List___Optional__List_OptionalAnyHashable(b)):
                return a == nil && b == nil || a == b
            default:
                return false
            }
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as [any pkl_swift_lib1.Being]:
                self = NestLists.listpkl_swift_lib1Being(decoded)
            case let decoded as [any pkl_swift_lib1.Being]?:
                self = NestLists.optional_Listpkl_swift_lib1Being(decoded)
            case let decoded as [(any pkl_swift_lib1.Being)?]:
                self = NestLists.list_Optionalpkl_swift_lib1Being(decoded)
            case let decoded as [(any pkl_swift_lib1.Being)?]?:
                self = NestLists.optional__List_Optionalpkl_swift_lib1Being(decoded)
            case let decoded as [[AnyHashable?]]:
                self = NestLists.list__List_OptionalAnyHashable(decoded)
            case let decoded as [[AnyHashable?]]?:
                self = NestLists.optional___List__List_OptionalAnyHashable(decoded)
            case let decoded as [[AnyHashable?]?]:
                self = NestLists.list___Optional__List_OptionalAnyHashable(decoded)
            case let decoded as [[AnyHashable?]?]?:
                self = NestLists.optional____List___Optional__List_OptionalAnyHashable(decoded)
            default:
                throw DecodingError.typeMismatch(
                    NestLists.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type NestLists, but got \(String(describing: value))"
                    )
                )
            }
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
            case let .listpkl_swift_lib1Being(value):
                hasher.combine("listpkl_swift_lib1Being")
                for x in value {
                    hasher.combine(x)
                }
            case let .optional_Listpkl_swift_lib1Being(value):
                hasher.combine("optional_Listpkl_swift_lib1Being")
                if let value {
                    for x in value {
                        hasher.combine(x)
                    }
                }
            case let .list_Optionalpkl_swift_lib1Being(value):
                hasher.combine("list_Optionalpkl_swift_lib1Being")
                for x in value {
                    if let x {
                        hasher.combine(x)
                    }
                }
            case let .optional__List_Optionalpkl_swift_lib1Being(value):
                hasher.combine("optional__List_Optionalpkl_swift_lib1Being")
                if let value {
                    for x in value {
                        if let x {
                            hasher.combine(x)
                        }
                    }
                }
            case let .list__List_OptionalAnyHashable(value):
                hasher.combine("list__List_OptionalAnyHashable")
                for x in value {
                    for x in x {
                        if let x {
                            hasher.combine(x)
                        }
                    }
                }
            case let .optional___List__List_OptionalAnyHashable(value):
                hasher.combine("optional___List__List_OptionalAnyHashable")
                if let value {
                    for x in value {
                        for x in x {
                            if let x {
                                hasher.combine(x)
                            }
                        }
                    }
                }
            case let .list___Optional__List_OptionalAnyHashable(value):
                hasher.combine("list___Optional__List_OptionalAnyHashable")
                for x in value {
                    if let x {
                        for x in x {
                            if let x {
                                hasher.combine(x)
                            }
                        }
                    }
                }
            case let .optional____List___Optional__List_OptionalAnyHashable(value):
                hasher.combine("optional____List___Optional__List_OptionalAnyHashable")
                if let value {
                    for x in value {
                        if let x {
                            for x in x {
                                if let x {
                                    hasher.combine(x)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public enum NestMappings: Decodable, Hashable, @unchecked Sendable {
        case mapping_pkl_swift_lib1Being_OptionalString([PklSwift.OptionalDictionaryKey<String>: any pkl_swift_lib1.Being])
        case optional__Mapping_pkl_swift_lib1Being_OptionalString([PklSwift.OptionalDictionaryKey<String>: any pkl_swift_lib1.Being]?)
        case mapping_Optionalpkl_swift_lib1Being_OptionalString([PklSwift.OptionalDictionaryKey<String>: (any pkl_swift_lib1.Being)?])
        case optional__Mapping_Optionalpkl_swift_lib1Being_OptionalString([PklSwift.OptionalDictionaryKey<String>: (any pkl_swift_lib1.Being)?]?)
        case mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalString([PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]])
        case optional___Mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalString([PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]]?)
        case mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalString([PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?])
        case optional____Mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalString([PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?]?)
        case mapping_pkl_swift_lib1Being_OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: any pkl_swift_lib1.Being])
        case optional__Mapping_pkl_swift_lib1Being_OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: any pkl_swift_lib1.Being]?)
        case mapping_Optionalpkl_swift_lib1Being_OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: (any pkl_swift_lib1.Being)?])
        case optional__Mapping_Optionalpkl_swift_lib1Being_OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: (any pkl_swift_lib1.Being)?]?)
        case mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]])
        case optional___Mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]]?)
        case mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?])
        case optional____Mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?]?)

        public static func ==(lhs: NestMappings, rhs: NestMappings) -> Bool {
            switch (lhs, rhs) {
            case let (.mapping_pkl_swift_lib1Being_OptionalString(a), .mapping_pkl_swift_lib1Being_OptionalString(b)):
                return mapEquals(map1: a, map2: b)
            case let (.optional__Mapping_pkl_swift_lib1Being_OptionalString(a), .optional__Mapping_pkl_swift_lib1Being_OptionalString(b)):
                return a == nil && b == nil || mapEquals(map1: a, map2: b)
            case let (.mapping_Optionalpkl_swift_lib1Being_OptionalString(a), .mapping_Optionalpkl_swift_lib1Being_OptionalString(b)):
                return mapEquals(map1: a, map2: b)
            case let (.optional__Mapping_Optionalpkl_swift_lib1Being_OptionalString(a), .optional__Mapping_Optionalpkl_swift_lib1Being_OptionalString(b)):
                return a == nil && b == nil || mapEquals(map1: a, map2: b)
            case let (.mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalString(a), .mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalString(b)):
                return a == b
            case let (.optional___Mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalString(a), .optional___Mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalString(b)):
                return a == nil && b == nil || a == b
            case let (.mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalString(a), .mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalString(b)):
                return a == b
            case let (.optional____Mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalString(a), .optional____Mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalString(b)):
                return a == nil && b == nil || a == b
            case let (.mapping_pkl_swift_lib1Being_OptionalObjectKey(a), .mapping_pkl_swift_lib1Being_OptionalObjectKey(b)):
                return mapEquals(map1: a, map2: b)
            case let (.optional__Mapping_pkl_swift_lib1Being_OptionalObjectKey(a), .optional__Mapping_pkl_swift_lib1Being_OptionalObjectKey(b)):
                return a == nil && b == nil || mapEquals(map1: a, map2: b)
            case let (.mapping_Optionalpkl_swift_lib1Being_OptionalObjectKey(a), .mapping_Optionalpkl_swift_lib1Being_OptionalObjectKey(b)):
                return mapEquals(map1: a, map2: b)
            case let (.optional__Mapping_Optionalpkl_swift_lib1Being_OptionalObjectKey(a), .optional__Mapping_Optionalpkl_swift_lib1Being_OptionalObjectKey(b)):
                return a == nil && b == nil || mapEquals(map1: a, map2: b)
            case let (.mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(a), .mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(b)):
                return a == b
            case let (.optional___Mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(a), .optional___Mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(b)):
                return a == nil && b == nil || a == b
            case let (.mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(a), .mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(b)):
                return a == b
            case let (.optional____Mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(a), .optional____Mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(b)):
                return a == nil && b == nil || a == b
            default:
                return false
            }
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: any pkl_swift_lib1.Being]:
                self = NestMappings.mapping_pkl_swift_lib1Being_OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: any pkl_swift_lib1.Being]?:
                self = NestMappings.optional__Mapping_pkl_swift_lib1Being_OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: (any pkl_swift_lib1.Being)?]:
                self = NestMappings.mapping_Optionalpkl_swift_lib1Being_OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: (any pkl_swift_lib1.Being)?]?:
                self = NestMappings.optional__Mapping_Optionalpkl_swift_lib1Being_OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]]:
                self = NestMappings.mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]]?:
                self = NestMappings.optional___Mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?]:
                self = NestMappings.mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?]?:
                self = NestMappings.optional____Mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: any pkl_swift_lib1.Being]:
                self = NestMappings.mapping_pkl_swift_lib1Being_OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: any pkl_swift_lib1.Being]?:
                self = NestMappings.optional__Mapping_pkl_swift_lib1Being_OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: (any pkl_swift_lib1.Being)?]:
                self = NestMappings.mapping_Optionalpkl_swift_lib1Being_OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: (any pkl_swift_lib1.Being)?]?:
                self = NestMappings.optional__Mapping_Optionalpkl_swift_lib1Being_OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]]:
                self = NestMappings.mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]]?:
                self = NestMappings.optional___Mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?]:
                self = NestMappings.mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?]?:
                self = NestMappings.optional____Mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(decoded)
            default:
                throw DecodingError.typeMismatch(
                    NestMappings.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type NestMappings, but got \(String(describing: value))"
                    )
                )
            }
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
            case let .mapping_pkl_swift_lib1Being_OptionalString(value):
                hasher.combine("mapping_pkl_swift_lib1Being_OptionalString")
                for (k, v) in value {
                    hasher.combine(k)
                    hasher.combine(v)
                }
            case let .optional__Mapping_pkl_swift_lib1Being_OptionalString(value):
                hasher.combine("optional__Mapping_pkl_swift_lib1Being_OptionalString")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        hasher.combine(v)
                    }
                }
            case let .mapping_Optionalpkl_swift_lib1Being_OptionalString(value):
                hasher.combine("mapping_Optionalpkl_swift_lib1Being_OptionalString")
                for (k, v) in value {
                    hasher.combine(k)
                    if let v {
                        hasher.combine(v)
                    }
                }
            case let .optional__Mapping_Optionalpkl_swift_lib1Being_OptionalString(value):
                hasher.combine("optional__Mapping_Optionalpkl_swift_lib1Being_OptionalString")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        if let v {
                            hasher.combine(v)
                        }
                    }
                }
            case let .mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalString(value):
                hasher.combine("mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalString")
                for (k, v) in value {
                    hasher.combine(k)
                    for (k, v) in v {
                        hasher.combine(k)
                        if let v {
                            hasher.combine(v)
                        }
                    }
                }
            case let .optional___Mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalString(value):
                hasher.combine("optional___Mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalString")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        for (k, v) in v {
                            hasher.combine(k)
                            if let v {
                                hasher.combine(v)
                            }
                        }
                    }
                }
            case let .mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalString(value):
                hasher.combine("mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalString")
                for (k, v) in value {
                    hasher.combine(k)
                    if let v {
                        for (k, v) in v {
                            hasher.combine(k)
                            if let v {
                                hasher.combine(v)
                            }
                        }
                    }
                }
            case let .optional____Mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalString(value):
                hasher.combine("optional____Mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalString")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        if let v {
                            for (k, v) in v {
                                hasher.combine(k)
                                if let v {
                                    hasher.combine(v)
                                }
                            }
                        }
                    }
                }
            case let .mapping_pkl_swift_lib1Being_OptionalObjectKey(value):
                hasher.combine("mapping_pkl_swift_lib1Being_OptionalObjectKey")
                for (k, v) in value {
                    hasher.combine(k)
                    hasher.combine(v)
                }
            case let .optional__Mapping_pkl_swift_lib1Being_OptionalObjectKey(value):
                hasher.combine("optional__Mapping_pkl_swift_lib1Being_OptionalObjectKey")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        hasher.combine(v)
                    }
                }
            case let .mapping_Optionalpkl_swift_lib1Being_OptionalObjectKey(value):
                hasher.combine("mapping_Optionalpkl_swift_lib1Being_OptionalObjectKey")
                for (k, v) in value {
                    hasher.combine(k)
                    if let v {
                        hasher.combine(v)
                    }
                }
            case let .optional__Mapping_Optionalpkl_swift_lib1Being_OptionalObjectKey(value):
                hasher.combine("optional__Mapping_Optionalpkl_swift_lib1Being_OptionalObjectKey")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        if let v {
                            hasher.combine(v)
                        }
                    }
                }
            case let .mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(value):
                hasher.combine("mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey")
                for (k, v) in value {
                    hasher.combine(k)
                    for (k, v) in v {
                        hasher.combine(k)
                        if let v {
                            hasher.combine(v)
                        }
                    }
                }
            case let .optional___Mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(value):
                hasher.combine("optional___Mapping__Mapping_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        for (k, v) in v {
                            hasher.combine(k)
                            if let v {
                                hasher.combine(v)
                            }
                        }
                    }
                }
            case let .mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(value):
                hasher.combine("mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey")
                for (k, v) in value {
                    hasher.combine(k)
                    if let v {
                        for (k, v) in v {
                            hasher.combine(k)
                            if let v {
                                hasher.combine(v)
                            }
                        }
                    }
                }
            case let .optional____Mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(value):
                hasher.combine("optional____Mapping___Optional__Mapping_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        if let v {
                            for (k, v) in v {
                                hasher.combine(k)
                                if let v {
                                    hasher.combine(v)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public enum NestMaps: Decodable, Hashable, @unchecked Sendable {
        case map_pkl_swift_lib1Being_OptionalString([PklSwift.OptionalDictionaryKey<String>: any pkl_swift_lib1.Being])
        case optional__Map_pkl_swift_lib1Being_OptionalString([PklSwift.OptionalDictionaryKey<String>: any pkl_swift_lib1.Being]?)
        case map_Optionalpkl_swift_lib1Being_OptionalString([PklSwift.OptionalDictionaryKey<String>: (any pkl_swift_lib1.Being)?])
        case optional__Map_Optionalpkl_swift_lib1Being_OptionalString([PklSwift.OptionalDictionaryKey<String>: (any pkl_swift_lib1.Being)?]?)
        case map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalString([PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]])
        case optional___Map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalString([PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]]?)
        case map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalString([PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?])
        case optional____Map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalString([PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?]?)
        case map_pkl_swift_lib1Being_OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: any pkl_swift_lib1.Being])
        case optional__Map_pkl_swift_lib1Being_OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: any pkl_swift_lib1.Being]?)
        case map_Optionalpkl_swift_lib1Being_OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: (any pkl_swift_lib1.Being)?])
        case optional__Map_Optionalpkl_swift_lib1Being_OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: (any pkl_swift_lib1.Being)?]?)
        case map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]])
        case optional___Map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]]?)
        case map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?])
        case optional____Map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey([PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?]?)

        public static func ==(lhs: NestMaps, rhs: NestMaps) -> Bool {
            switch (lhs, rhs) {
            case let (.map_pkl_swift_lib1Being_OptionalString(a), .map_pkl_swift_lib1Being_OptionalString(b)):
                return mapEquals(map1: a, map2: b)
            case let (.optional__Map_pkl_swift_lib1Being_OptionalString(a), .optional__Map_pkl_swift_lib1Being_OptionalString(b)):
                return a == nil && b == nil || mapEquals(map1: a, map2: b)
            case let (.map_Optionalpkl_swift_lib1Being_OptionalString(a), .map_Optionalpkl_swift_lib1Being_OptionalString(b)):
                return mapEquals(map1: a, map2: b)
            case let (.optional__Map_Optionalpkl_swift_lib1Being_OptionalString(a), .optional__Map_Optionalpkl_swift_lib1Being_OptionalString(b)):
                return a == nil && b == nil || mapEquals(map1: a, map2: b)
            case let (.map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalString(a), .map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalString(b)):
                return a == b
            case let (.optional___Map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalString(a), .optional___Map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalString(b)):
                return a == nil && b == nil || a == b
            case let (.map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalString(a), .map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalString(b)):
                return a == b
            case let (.optional____Map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalString(a), .optional____Map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalString(b)):
                return a == nil && b == nil || a == b
            case let (.map_pkl_swift_lib1Being_OptionalObjectKey(a), .map_pkl_swift_lib1Being_OptionalObjectKey(b)):
                return mapEquals(map1: a, map2: b)
            case let (.optional__Map_pkl_swift_lib1Being_OptionalObjectKey(a), .optional__Map_pkl_swift_lib1Being_OptionalObjectKey(b)):
                return a == nil && b == nil || mapEquals(map1: a, map2: b)
            case let (.map_Optionalpkl_swift_lib1Being_OptionalObjectKey(a), .map_Optionalpkl_swift_lib1Being_OptionalObjectKey(b)):
                return mapEquals(map1: a, map2: b)
            case let (.optional__Map_Optionalpkl_swift_lib1Being_OptionalObjectKey(a), .optional__Map_Optionalpkl_swift_lib1Being_OptionalObjectKey(b)):
                return a == nil && b == nil || mapEquals(map1: a, map2: b)
            case let (.map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(a), .map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(b)):
                return a == b
            case let (.optional___Map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(a), .optional___Map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(b)):
                return a == nil && b == nil || a == b
            case let (.map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(a), .map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(b)):
                return a == b
            case let (.optional____Map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(a), .optional____Map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(b)):
                return a == nil && b == nil || a == b
            default:
                return false
            }
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: any pkl_swift_lib1.Being]:
                self = NestMaps.map_pkl_swift_lib1Being_OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: any pkl_swift_lib1.Being]?:
                self = NestMaps.optional__Map_pkl_swift_lib1Being_OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: (any pkl_swift_lib1.Being)?]:
                self = NestMaps.map_Optionalpkl_swift_lib1Being_OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: (any pkl_swift_lib1.Being)?]?:
                self = NestMaps.optional__Map_Optionalpkl_swift_lib1Being_OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]]:
                self = NestMaps.map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]]?:
                self = NestMaps.optional___Map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?]:
                self = NestMaps.map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?]?:
                self = NestMaps.optional____Map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalString(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: any pkl_swift_lib1.Being]:
                self = NestMaps.map_pkl_swift_lib1Being_OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: any pkl_swift_lib1.Being]?:
                self = NestMaps.optional__Map_pkl_swift_lib1Being_OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: (any pkl_swift_lib1.Being)?]:
                self = NestMaps.map_Optionalpkl_swift_lib1Being_OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: (any pkl_swift_lib1.Being)?]?:
                self = NestMaps.optional__Map_Optionalpkl_swift_lib1Being_OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]]:
                self = NestMaps.map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]]?:
                self = NestMaps.optional___Map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?]:
                self = NestMaps.map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(decoded)
            case let decoded as [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?]?:
                self = NestMaps.optional____Map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(decoded)
            default:
                throw DecodingError.typeMismatch(
                    NestMaps.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type NestMaps, but got \(String(describing: value))"
                    )
                )
            }
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
            case let .map_pkl_swift_lib1Being_OptionalString(value):
                hasher.combine("map_pkl_swift_lib1Being_OptionalString")
                for (k, v) in value {
                    hasher.combine(k)
                    hasher.combine(v)
                }
            case let .optional__Map_pkl_swift_lib1Being_OptionalString(value):
                hasher.combine("optional__Map_pkl_swift_lib1Being_OptionalString")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        hasher.combine(v)
                    }
                }
            case let .map_Optionalpkl_swift_lib1Being_OptionalString(value):
                hasher.combine("map_Optionalpkl_swift_lib1Being_OptionalString")
                for (k, v) in value {
                    hasher.combine(k)
                    if let v {
                        hasher.combine(v)
                    }
                }
            case let .optional__Map_Optionalpkl_swift_lib1Being_OptionalString(value):
                hasher.combine("optional__Map_Optionalpkl_swift_lib1Being_OptionalString")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        if let v {
                            hasher.combine(v)
                        }
                    }
                }
            case let .map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalString(value):
                hasher.combine("map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalString")
                for (k, v) in value {
                    hasher.combine(k)
                    for (k, v) in v {
                        hasher.combine(k)
                        if let v {
                            hasher.combine(v)
                        }
                    }
                }
            case let .optional___Map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalString(value):
                hasher.combine("optional___Map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalString")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        for (k, v) in v {
                            hasher.combine(k)
                            if let v {
                                hasher.combine(v)
                            }
                        }
                    }
                }
            case let .map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalString(value):
                hasher.combine("map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalString")
                for (k, v) in value {
                    hasher.combine(k)
                    if let v {
                        for (k, v) in v {
                            hasher.combine(k)
                            if let v {
                                hasher.combine(v)
                            }
                        }
                    }
                }
            case let .optional____Map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalString(value):
                hasher.combine("optional____Map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalString")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        if let v {
                            for (k, v) in v {
                                hasher.combine(k)
                                if let v {
                                    hasher.combine(v)
                                }
                            }
                        }
                    }
                }
            case let .map_pkl_swift_lib1Being_OptionalObjectKey(value):
                hasher.combine("map_pkl_swift_lib1Being_OptionalObjectKey")
                for (k, v) in value {
                    hasher.combine(k)
                    hasher.combine(v)
                }
            case let .optional__Map_pkl_swift_lib1Being_OptionalObjectKey(value):
                hasher.combine("optional__Map_pkl_swift_lib1Being_OptionalObjectKey")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        hasher.combine(v)
                    }
                }
            case let .map_Optionalpkl_swift_lib1Being_OptionalObjectKey(value):
                hasher.combine("map_Optionalpkl_swift_lib1Being_OptionalObjectKey")
                for (k, v) in value {
                    hasher.combine(k)
                    if let v {
                        hasher.combine(v)
                    }
                }
            case let .optional__Map_Optionalpkl_swift_lib1Being_OptionalObjectKey(value):
                hasher.combine("optional__Map_Optionalpkl_swift_lib1Being_OptionalObjectKey")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        if let v {
                            hasher.combine(v)
                        }
                    }
                }
            case let .map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(value):
                hasher.combine("map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey")
                for (k, v) in value {
                    hasher.combine(k)
                    for (k, v) in v {
                        hasher.combine(k)
                        if let v {
                            hasher.combine(v)
                        }
                    }
                }
            case let .optional___Map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey(value):
                hasher.combine("optional___Map__Map_OptionalAnyHashable_OptionalAnyHashable__OptionalObjectKey")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        for (k, v) in v {
                            hasher.combine(k)
                            if let v {
                                hasher.combine(v)
                            }
                        }
                    }
                }
            case let .map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(value):
                hasher.combine("map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey")
                for (k, v) in value {
                    hasher.combine(k)
                    if let v {
                        for (k, v) in v {
                            hasher.combine(k)
                            if let v {
                                hasher.combine(v)
                            }
                        }
                    }
                }
            case let .optional____Map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey(value):
                hasher.combine("optional____Map___Optional__Map_OptionalAnyHashable_OptionalAnyHashable___OptionalObjectKey")
                if let value {
                    for (k, v) in value {
                        hasher.combine(k)
                        if let v {
                            for (k, v) in v {
                                hasher.combine(k)
                                if let v {
                                    hasher.combine(v)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public enum SameResultType: Decodable, Hashable, Sendable {
        case listingString([String])
        case listString([String])
        case mappingStringString([String: String])
        case mapStringString([String: String])

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as [String]:
                self = SameResultType.listingString(decoded)
            case let decoded as [String]:
                self = SameResultType.listString(decoded)
            case let decoded as [String: String]:
                self = SameResultType.mappingStringString(decoded)
            case let decoded as [String: String]:
                self = SameResultType.mapStringString(decoded)
            default:
                throw DecodingError.typeMismatch(
                    SameResultType.self,
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected type SameResultType, but got \(String(describing: value))"
                    )
                )
            }
        }
    }

    public struct Module: PklRegisteredType, Decodable, Hashable, @unchecked Sendable {
        public static let registeredIdentifier: String = "pkl.swift.example.Poly"

        public var beings: [any pkl_swift_lib1.Being]

        public var beings2: [any pkl_swift_lib1.Being]?

        public var beings3: [(any pkl_swift_lib1.Being)?]

        public var beings4: [(any pkl_swift_lib1.Being)?]?

        public var dogs: [Dog]?

        public var rex: Dog

        public var moreBeings: [String: any pkl_swift_lib1.Being]

        public var moreBeings2: [String: any pkl_swift_lib1.Being]?

        public var moreBeings3: [String: (any pkl_swift_lib1.Being)?]?

        public var moreBeings4: [String: (any pkl_swift_lib1.Being)?]

        public var nestListing1: [[AnyHashable?]]

        public var nestListing2: [[AnyHashable?]]?

        public var nestListing3: [[AnyHashable?]?]

        public var nestListing4: [[AnyHashable?]?]?

        public var nestListings: NestListings

        public var nestList1: [[AnyHashable?]]

        public var nestList2: [[AnyHashable?]]?

        public var nestList3: [[AnyHashable?]?]

        public var nestList4: [[AnyHashable?]?]?

        public var nestLists: NestLists

        public var nestMapping1: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]]

        public var nestMapping2: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]]?

        public var nestMapping3: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?]

        public var nestMapping4: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?]?

        public var nestMappingObj1: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]]

        public var nestMappingObj2: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]]?

        public var nestMappingObj3: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?]

        public var nestMappingObj4: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?]?

        public var nestMappings: NestMappings

        public var nestMap1: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]]

        public var nestMap2: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]]?

        public var nestMap3: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?]

        public var nestMap4: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?]?

        public var nestMapObj1: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]]

        public var nestMapObj2: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]]?

        public var nestMapObj3: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?]

        public var nestMapObj4: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?]?

        public var nestMaps: NestMaps

        public var sameResultType: SameResultType

        public var foosListing: [Foo]

        public var foosMapping: [String: Foo]

        public init(
            beings: [any pkl_swift_lib1.Being],
            beings2: [any pkl_swift_lib1.Being]?,
            beings3: [(any pkl_swift_lib1.Being)?],
            beings4: [(any pkl_swift_lib1.Being)?]?,
            dogs: [Dog]?,
            rex: Dog,
            moreBeings: [String: any pkl_swift_lib1.Being],
            moreBeings2: [String: any pkl_swift_lib1.Being]?,
            moreBeings3: [String: (any pkl_swift_lib1.Being)?]?,
            moreBeings4: [String: (any pkl_swift_lib1.Being)?],
            nestListing1: [[AnyHashable?]],
            nestListing2: [[AnyHashable?]]?,
            nestListing3: [[AnyHashable?]?],
            nestListing4: [[AnyHashable?]?]?,
            nestListings: NestListings,
            nestList1: [[AnyHashable?]],
            nestList2: [[AnyHashable?]]?,
            nestList3: [[AnyHashable?]?],
            nestList4: [[AnyHashable?]?]?,
            nestLists: NestLists,
            nestMapping1: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]],
            nestMapping2: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]]?,
            nestMapping3: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?],
            nestMapping4: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?]?,
            nestMappingObj1: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]],
            nestMappingObj2: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]]?,
            nestMappingObj3: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?],
            nestMappingObj4: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?]?,
            nestMappings: NestMappings,
            nestMap1: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]],
            nestMap2: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]]?,
            nestMap3: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?],
            nestMap4: [PklSwift.OptionalDictionaryKey<String>: [AnyHashable?: AnyHashable?]?]?,
            nestMapObj1: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]],
            nestMapObj2: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]]?,
            nestMapObj3: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?],
            nestMapObj4: [PklSwift.OptionalDictionaryKey<ObjectKey>: [AnyHashable?: AnyHashable?]?]?,
            nestMaps: NestMaps,
            sameResultType: SameResultType,
            foosListing: [Foo],
            foosMapping: [String: Foo]
        ) {
            self.beings = beings
            self.beings2 = beings2
            self.beings3 = beings3
            self.beings4 = beings4
            self.dogs = dogs
            self.rex = rex
            self.moreBeings = moreBeings
            self.moreBeings2 = moreBeings2
            self.moreBeings3 = moreBeings3
            self.moreBeings4 = moreBeings4
            self.nestListing1 = nestListing1
            self.nestListing2 = nestListing2
            self.nestListing3 = nestListing3
            self.nestListing4 = nestListing4
            self.nestListings = nestListings
            self.nestList1 = nestList1
            self.nestList2 = nestList2
            self.nestList3 = nestList3
            self.nestList4 = nestList4
            self.nestLists = nestLists
            self.nestMapping1 = nestMapping1
            self.nestMapping2 = nestMapping2
            self.nestMapping3 = nestMapping3
            self.nestMapping4 = nestMapping4
            self.nestMappingObj1 = nestMappingObj1
            self.nestMappingObj2 = nestMappingObj2
            self.nestMappingObj3 = nestMappingObj3
            self.nestMappingObj4 = nestMappingObj4
            self.nestMappings = nestMappings
            self.nestMap1 = nestMap1
            self.nestMap2 = nestMap2
            self.nestMap3 = nestMap3
            self.nestMap4 = nestMap4
            self.nestMapObj1 = nestMapObj1
            self.nestMapObj2 = nestMapObj2
            self.nestMapObj3 = nestMapObj3
            self.nestMapObj4 = nestMapObj4
            self.nestMaps = nestMaps
            self.sameResultType = sameResultType
            self.foosListing = foosListing
            self.foosMapping = foosMapping
        }

        public static func ==(lhs: Module, rhs: Module) -> Bool {
            arrayEquals(arr1: lhs.beings, arr2: rhs.beings)
            && lhs.beings2 == nil && rhs.beings2 == nil || arrayEquals(arr1: lhs.beings2, arr2: rhs.beings2)
            && arrayEquals(arr1: lhs.beings3, arr2: rhs.beings3)
            && lhs.beings4 == nil && rhs.beings4 == nil || arrayEquals(arr1: lhs.beings4, arr2: rhs.beings4)
            && lhs.dogs == nil && rhs.dogs == nil || lhs.dogs == rhs.dogs
            && lhs.rex == rhs.rex
            && mapEquals(map1: lhs.moreBeings, map2: rhs.moreBeings)
            && lhs.moreBeings2 == nil && rhs.moreBeings2 == nil || mapEquals(map1: lhs.moreBeings2, map2: rhs.moreBeings2)
            && lhs.moreBeings3 == nil && rhs.moreBeings3 == nil || mapEquals(map1: lhs.moreBeings3, map2: rhs.moreBeings3)
            && mapEquals(map1: lhs.moreBeings4, map2: rhs.moreBeings4)
            && lhs.nestListing1 == rhs.nestListing1
            && lhs.nestListing2 == nil && rhs.nestListing2 == nil || lhs.nestListing2 == rhs.nestListing2
            && lhs.nestListing3 == rhs.nestListing3
            && lhs.nestListing4 == nil && rhs.nestListing4 == nil || lhs.nestListing4 == rhs.nestListing4
            && lhs.nestListings == rhs.nestListings
            && lhs.nestList1 == rhs.nestList1
            && lhs.nestList2 == nil && rhs.nestList2 == nil || lhs.nestList2 == rhs.nestList2
            && lhs.nestList3 == rhs.nestList3
            && lhs.nestList4 == nil && rhs.nestList4 == nil || lhs.nestList4 == rhs.nestList4
            && lhs.nestLists == rhs.nestLists
            && lhs.nestMapping1 == rhs.nestMapping1
            && lhs.nestMapping2 == nil && rhs.nestMapping2 == nil || lhs.nestMapping2 == rhs.nestMapping2
            && lhs.nestMapping3 == rhs.nestMapping3
            && lhs.nestMapping4 == nil && rhs.nestMapping4 == nil || lhs.nestMapping4 == rhs.nestMapping4
            && lhs.nestMappingObj1 == rhs.nestMappingObj1
            && lhs.nestMappingObj2 == nil && rhs.nestMappingObj2 == nil || lhs.nestMappingObj2 == rhs.nestMappingObj2
            && lhs.nestMappingObj3 == rhs.nestMappingObj3
            && lhs.nestMappingObj4 == nil && rhs.nestMappingObj4 == nil || lhs.nestMappingObj4 == rhs.nestMappingObj4
            && lhs.nestMappings == rhs.nestMappings
            && lhs.nestMap1 == rhs.nestMap1
            && lhs.nestMap2 == nil && rhs.nestMap2 == nil || lhs.nestMap2 == rhs.nestMap2
            && lhs.nestMap3 == rhs.nestMap3
            && lhs.nestMap4 == nil && rhs.nestMap4 == nil || lhs.nestMap4 == rhs.nestMap4
            && lhs.nestMapObj1 == rhs.nestMapObj1
            && lhs.nestMapObj2 == nil && rhs.nestMapObj2 == nil || lhs.nestMapObj2 == rhs.nestMapObj2
            && lhs.nestMapObj3 == rhs.nestMapObj3
            && lhs.nestMapObj4 == nil && rhs.nestMapObj4 == nil || lhs.nestMapObj4 == rhs.nestMapObj4
            && lhs.nestMaps == rhs.nestMaps
            && lhs.sameResultType == rhs.sameResultType
            && lhs.foosListing == rhs.foosListing
            && lhs.foosMapping == rhs.foosMapping
        }

        public func hash(into hasher: inout Hasher) {
            for x in beings {
                hasher.combine(x)
            }
            if let beings2 {
                for x in beings2 {
                    hasher.combine(x)
                }
            }
            for x in beings3 {
                if let x {
                    hasher.combine(x)
                }
            }
            if let beings4 {
                for x in beings4 {
                    if let x {
                        hasher.combine(x)
                    }
                }
            }
            hasher.combine(dogs)
            hasher.combine(rex)
            for (k, v) in moreBeings {
                hasher.combine(k)
                hasher.combine(v)
            }
            if let moreBeings2 {
                for (k, v) in moreBeings2 {
                    hasher.combine(k)
                    hasher.combine(v)
                }
            }
            if let moreBeings3 {
                for (k, v) in moreBeings3 {
                    hasher.combine(k)
                    if let v {
                        hasher.combine(v)
                    }
                }
            }
            for (k, v) in moreBeings4 {
                hasher.combine(k)
                if let v {
                    hasher.combine(v)
                }
            }
            hasher.combine(nestListing1)
            hasher.combine(nestListing2)
            hasher.combine(nestListing3)
            hasher.combine(nestListing4)
            hasher.combine(nestListings)
            hasher.combine(nestList1)
            hasher.combine(nestList2)
            hasher.combine(nestList3)
            hasher.combine(nestList4)
            hasher.combine(nestLists)
            hasher.combine(nestMapping1)
            hasher.combine(nestMapping2)
            hasher.combine(nestMapping3)
            hasher.combine(nestMapping4)
            hasher.combine(nestMappingObj1)
            hasher.combine(nestMappingObj2)
            hasher.combine(nestMappingObj3)
            hasher.combine(nestMappingObj4)
            hasher.combine(nestMappings)
            hasher.combine(nestMap1)
            hasher.combine(nestMap2)
            hasher.combine(nestMap3)
            hasher.combine(nestMap4)
            hasher.combine(nestMapObj1)
            hasher.combine(nestMapObj2)
            hasher.combine(nestMapObj3)
            hasher.combine(nestMapObj4)
            hasher.combine(nestMaps)
            hasher.combine(sameResultType)
            hasher.combine(foosListing)
            hasher.combine(foosMapping)
        }

        public init(from decoder: any Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let beings = try dec.decode([PklSwift.PklAny].self, forKey: PklCodingKey(string: "beings"))
                .map {
                    $0.value as! any pkl_swift_lib1.Being
                }
            let beings2 = try dec.decode([PklSwift.PklAny]?.self, forKey: PklCodingKey(string: "beings2"))?
                .map {
                    $0.value as! any pkl_swift_lib1.Being
                }
            let beings3 = try dec.decode([PklSwift.PklAny].self, forKey: PklCodingKey(string: "beings3"))
                .map {
                    $0.value as! (any pkl_swift_lib1.Being)?
                }
            let beings4 = try dec.decode([PklSwift.PklAny]?.self, forKey: PklCodingKey(string: "beings4"))?
                .map {
                    $0.value as! (any pkl_swift_lib1.Being)?
                }
            let dogs = try dec.decode([Dog]?.self, forKey: PklCodingKey(string: "dogs"))
            let rex = try dec.decode(Dog.self, forKey: PklCodingKey(string: "rex"))
            let moreBeings = try dec.decode([String: PklSwift.PklAny].self, forKey: PklCodingKey(string: "moreBeings"))
                .mapValues {
                    $0.value as! any pkl_swift_lib1.Being
                }
            let moreBeings2 = try dec.decode([String: PklSwift.PklAny]?.self, forKey: PklCodingKey(string: "moreBeings2"))?
                .mapValues {
                    $0.value as! any pkl_swift_lib1.Being
                }
            let moreBeings3 = try dec.decode([String: PklSwift.PklAny]?.self, forKey: PklCodingKey(string: "moreBeings3"))?
                .mapValues {
                    $0.value as! (any pkl_swift_lib1.Being)?
                }
            let moreBeings4 = try dec.decode([String: PklSwift.PklAny].self, forKey: PklCodingKey(string: "moreBeings4"))
                .mapValues {
                    $0.value as! (any pkl_swift_lib1.Being)?
                }
            let nestListing1 = try dec.decode([[PklSwift.PklAny]].self, forKey: PklCodingKey(string: "nestListing1"))
                .map {
                    $0.map {
                        $0.value
                    }
                }
            let nestListing2 = try dec.decode([[PklSwift.PklAny]]?.self, forKey: PklCodingKey(string: "nestListing2"))?
                .map {
                    $0.map {
                        $0.value
                    }
                }
            let nestListing3 = try dec.decode([[PklSwift.PklAny]?].self, forKey: PklCodingKey(string: "nestListing3"))
                .map {
                    $0?.map {
                        $0.value
                    }
                }
            let nestListing4 = try dec.decode([[PklSwift.PklAny]?]?.self, forKey: PklCodingKey(string: "nestListing4"))?
                .map {
                    $0?.map {
                        $0.value
                    }
                }
            let nestListings = try dec.decode(NestListings.self, forKey: PklCodingKey(string: "nestListings"))
            let nestList1 = try dec.decode([[PklSwift.PklAny]].self, forKey: PklCodingKey(string: "nestList1"))
                .map {
                    $0.map {
                        $0.value
                    }
                }
            let nestList2 = try dec.decode([[PklSwift.PklAny]]?.self, forKey: PklCodingKey(string: "nestList2"))?
                .map {
                    $0.map {
                        $0.value
                    }
                }
            let nestList3 = try dec.decode([[PklSwift.PklAny]?].self, forKey: PklCodingKey(string: "nestList3"))
                .map {
                    $0?.map {
                        $0.value
                    }
                }
            let nestList4 = try dec.decode([[PklSwift.PklAny]?]?.self, forKey: PklCodingKey(string: "nestList4"))?
                .map {
                    $0?.map {
                        $0.value
                    }
                }
            let nestLists = try dec.decode(NestLists.self, forKey: PklCodingKey(string: "nestLists"))
            let nestMapping1 = try dec.decode([PklSwift.OptionalDictionaryKey<String>: [PklSwift.PklAny: PklSwift.PklAny]].self, forKey: PklCodingKey(string: "nestMapping1"))
                .mapValues {
                    $0.mapValues {
                        $0.value
                    }
                }
            let nestMapping2 = try dec.decode([PklSwift.OptionalDictionaryKey<String>: [PklSwift.PklAny: PklSwift.PklAny]]?.self, forKey: PklCodingKey(string: "nestMapping2"))?
                .mapValues {
                    $0.mapValues {
                        $0.value
                    }
                }
            let nestMapping3 = try dec.decode([PklSwift.OptionalDictionaryKey<String>: [PklSwift.PklAny: PklSwift.PklAny]?].self, forKey: PklCodingKey(string: "nestMapping3"))
                .mapValues {
                    $0?.mapValues {
                        $0.value
                    }
                }
            let nestMapping4 = try dec.decode([PklSwift.OptionalDictionaryKey<String>: [PklSwift.PklAny: PklSwift.PklAny]?]?.self, forKey: PklCodingKey(string: "nestMapping4"))?
                .mapValues {
                    $0?.mapValues {
                        $0.value
                    }
                }
            let nestMappingObj1 = try dec.decode([PklSwift.OptionalDictionaryKey<ObjectKey>: [PklSwift.PklAny: PklSwift.PklAny]].self, forKey: PklCodingKey(string: "nestMappingObj1"))
                .mapValues {
                    $0.mapValues {
                        $0.value
                    }
                }
            let nestMappingObj2 = try dec.decode([PklSwift.OptionalDictionaryKey<ObjectKey>: [PklSwift.PklAny: PklSwift.PklAny]]?.self, forKey: PklCodingKey(string: "nestMappingObj2"))?
                .mapValues {
                    $0.mapValues {
                        $0.value
                    }
                }
            let nestMappingObj3 = try dec.decode([PklSwift.OptionalDictionaryKey<ObjectKey>: [PklSwift.PklAny: PklSwift.PklAny]?].self, forKey: PklCodingKey(string: "nestMappingObj3"))
                .mapValues {
                    $0?.mapValues {
                        $0.value
                    }
                }
            let nestMappingObj4 = try dec.decode([PklSwift.OptionalDictionaryKey<ObjectKey>: [PklSwift.PklAny: PklSwift.PklAny]?]?.self, forKey: PklCodingKey(string: "nestMappingObj4"))?
                .mapValues {
                    $0?.mapValues {
                        $0.value
                    }
                }
            let nestMappings = try dec.decode(NestMappings.self, forKey: PklCodingKey(string: "nestMappings"))
            let nestMap1 = try dec.decode([PklSwift.OptionalDictionaryKey<String>: [PklSwift.PklAny: PklSwift.PklAny]].self, forKey: PklCodingKey(string: "nestMap1"))
                .mapValues {
                    $0.mapValues {
                        $0.value
                    }
                }
            let nestMap2 = try dec.decode([PklSwift.OptionalDictionaryKey<String>: [PklSwift.PklAny: PklSwift.PklAny]]?.self, forKey: PklCodingKey(string: "nestMap2"))?
                .mapValues {
                    $0.mapValues {
                        $0.value
                    }
                }
            let nestMap3 = try dec.decode([PklSwift.OptionalDictionaryKey<String>: [PklSwift.PklAny: PklSwift.PklAny]?].self, forKey: PklCodingKey(string: "nestMap3"))
                .mapValues {
                    $0?.mapValues {
                        $0.value
                    }
                }
            let nestMap4 = try dec.decode([PklSwift.OptionalDictionaryKey<String>: [PklSwift.PklAny: PklSwift.PklAny]?]?.self, forKey: PklCodingKey(string: "nestMap4"))?
                .mapValues {
                    $0?.mapValues {
                        $0.value
                    }
                }
            let nestMapObj1 = try dec.decode([PklSwift.OptionalDictionaryKey<ObjectKey>: [PklSwift.PklAny: PklSwift.PklAny]].self, forKey: PklCodingKey(string: "nestMapObj1"))
                .mapValues {
                    $0.mapValues {
                        $0.value
                    }
                }
            let nestMapObj2 = try dec.decode([PklSwift.OptionalDictionaryKey<ObjectKey>: [PklSwift.PklAny: PklSwift.PklAny]]?.self, forKey: PklCodingKey(string: "nestMapObj2"))?
                .mapValues {
                    $0.mapValues {
                        $0.value
                    }
                }
            let nestMapObj3 = try dec.decode([PklSwift.OptionalDictionaryKey<ObjectKey>: [PklSwift.PklAny: PklSwift.PklAny]?].self, forKey: PklCodingKey(string: "nestMapObj3"))
                .mapValues {
                    $0?.mapValues {
                        $0.value
                    }
                }
            let nestMapObj4 = try dec.decode([PklSwift.OptionalDictionaryKey<ObjectKey>: [PklSwift.PklAny: PklSwift.PklAny]?]?.self, forKey: PklCodingKey(string: "nestMapObj4"))?
                .mapValues {
                    $0?.mapValues {
                        $0.value
                    }
                }
            let nestMaps = try dec.decode(NestMaps.self, forKey: PklCodingKey(string: "nestMaps"))
            let sameResultType = try dec.decode(SameResultType.self, forKey: PklCodingKey(string: "sameResultType"))
            let foosListing = try dec.decode([Foo].self, forKey: PklCodingKey(string: "foosListing"))
            let foosMapping = try dec.decode([String: Foo].self, forKey: PklCodingKey(string: "foosMapping"))
            self = Module(beings: beings, beings2: beings2, beings3: beings3, beings4: beings4, dogs: dogs, rex: rex, moreBeings: moreBeings, moreBeings2: moreBeings2, moreBeings3: moreBeings3, moreBeings4: moreBeings4, nestListing1: nestListing1, nestListing2: nestListing2, nestListing3: nestListing3, nestListing4: nestListing4, nestListings: nestListings, nestList1: nestList1, nestList2: nestList2, nestList3: nestList3, nestList4: nestList4, nestLists: nestLists, nestMapping1: nestMapping1, nestMapping2: nestMapping2, nestMapping3: nestMapping3, nestMapping4: nestMapping4, nestMappingObj1: nestMappingObj1, nestMappingObj2: nestMappingObj2, nestMappingObj3: nestMappingObj3, nestMappingObj4: nestMappingObj4, nestMappings: nestMappings, nestMap1: nestMap1, nestMap2: nestMap2, nestMap3: nestMap3, nestMap4: nestMap4, nestMapObj1: nestMapObj1, nestMapObj2: nestMapObj2, nestMapObj3: nestMapObj3, nestMapObj4: nestMapObj4, nestMaps: nestMaps, sameResultType: sameResultType, foosListing: foosListing, foosMapping: foosMapping)
        }
    }

    public struct Dog: Animal {
        public static let registeredIdentifier: String = "pkl.swift.example.Poly#Dog"

        public var barks: Bool

        public var hates: (any Animal)?

        public var name: String

        public var exists: Bool

        public init(barks: Bool, hates: (any Animal)?, name: String, exists: Bool) {
            self.barks = barks
            self.hates = hates
            self.name = name
            self.exists = exists
        }

        public static func ==(lhs: Dog, rhs: Dog) -> Bool {
            lhs.barks == rhs.barks
            && lhs.hates == nil && rhs.hates == nil || lhs.hates?.isDynamicallyEqual(to: rhs.hates) ?? false
            && lhs.name == rhs.name
            && lhs.exists == rhs.exists
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(barks)
            if let hates {
                hasher.combine(hates)
            }
            hasher.combine(name)
            hasher.combine(exists)
        }

        public init(from decoder: any Decoder) throws {
            let dec = try decoder.container(keyedBy: PklCodingKey.self)
            let barks = try dec.decode(Bool.self, forKey: PklCodingKey(string: "barks"))
            let hates = try dec.decode(PklSwift.PklAny.self, forKey: PklCodingKey(string: "hates"))
                .value as! (any Animal)?
            let name = try dec.decode(String.self, forKey: PklCodingKey(string: "name"))
            let exists = try dec.decode(Bool.self, forKey: PklCodingKey(string: "exists"))
            self = Dog(barks: barks, hates: hates, name: name, exists: exists)
        }
    }

    public typealias Animal = pkl_swift_example_Poly_Animal

    public struct AnimalImpl: Animal {
        public static let registeredIdentifier: String = "pkl.swift.example.Poly#Animal"

        public var name: String

        public var exists: Bool

        public init(name: String, exists: Bool) {
            self.name = name
            self.exists = exists
        }
    }

    public struct ObjectKey: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "pkl.swift.example.Poly#ObjectKey"

        public var str: String

        public var num: Int

        public init(str: String, num: Int) {
            self.str = str
            self.num = num
        }
    }

    public struct Foo: PklRegisteredType, Decodable, Hashable, Sendable {
        public static let registeredIdentifier: String = "pkl.swift.example.Poly#Foo"

        public var name: String

        public var bars: [String]?

        public init(name: String, bars: [String]?) {
            self.name = name
            self.bars = bars
        }
    }

    public struct Bird: pkl_swift_lib1.Being {
        public static let registeredIdentifier: String = "pkl.swift.example.Poly#Bird"

        public var name: String

        public var flies: Bool

        public var exists: Bool

        public init(name: String, flies: Bool, exists: Bool) {
            self.name = name
            self.flies = flies
            self.exists = exists
        }
    }

    /// Load the Pkl module at the given source and evaluate it into `pkl_swift_example_Poly.Module`.
    ///
    /// - Parameter source: The source of the Pkl module.
    public static func loadFrom(source: ModuleSource) async throws -> pkl_swift_example_Poly.Module {
        try await PklSwift.withEvaluator { evaluator in
            try await loadFrom(evaluator: evaluator, source: source)
        }
    }

    /// Load the Pkl module at the given source and evaluate it with the given evaluator into
    /// `pkl_swift_example_Poly.Module`.
    ///
    /// - Parameter evaluator: The evaluator to use for evaluation.
    /// - Parameter source: The module to evaluate.
    public static func loadFrom(
        evaluator: PklSwift.Evaluator,
        source: PklSwift.ModuleSource
    ) async throws -> pkl_swift_example_Poly.Module {
        try await evaluator.evaluateModule(source: source, as: Module.self)
    }
}