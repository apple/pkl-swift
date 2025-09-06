// Code generated from Pkl module `pkl.swift.example.Poly`. DO NOT EDIT.
import PklSwift

public enum pkl_swift_example_Poly {}

public protocol pkl_swift_example_Poly_Animal: pkl_swift_lib1_Being {
    var name: String { get }
}

extension pkl_swift_example_Poly {
    public enum NestListings: Decodable, Hashable {
        case arraypkl_swift_lib1Being([any pkl_swift_lib1.Being])
        case optionalArray_pkl_swift_lib1Being([any pkl_swift_lib1.Being]?)
        case arrayOptional_pkl_swift_lib1Being([(any pkl_swift_lib1.Being)?])
        case optionalArray_Optional__pkl_swift_lib1Being([(any pkl_swift_lib1.Being)?]?)
        case arrayArray_Optional__AnyHashable([[AnyHashable?]])
        case optionalArray_Array__Optional___AnyHashable([[AnyHashable?]]?)
        case arrayOptional_Array__Optional___AnyHashable([[AnyHashable?]?])
        case optionalArray_Optional__Array___Optional____AnyHashable([[AnyHashable?]?]?)

        public static func ==(lhs: NestListings, rhs: NestListings) -> Bool {
            switch (lhs, rhs) {
            case let (.arraypkl_swift_lib1Being(a), .arraypkl_swift_lib1Being(b)):
                return arrayEquals(arr1: a, arr2: b)
            case let (.optionalArray_pkl_swift_lib1Being(a), .optionalArray_pkl_swift_lib1Being(b)):
                return a == nil && b == nil || arrayEquals(arr1: a, arr2: b)
            case let (.arrayOptional_pkl_swift_lib1Being(a), .arrayOptional_pkl_swift_lib1Being(b)):
                return arrayEquals(arr1: a, arr2: b)
            case let (.optionalArray_Optional__pkl_swift_lib1Being(a), .optionalArray_Optional__pkl_swift_lib1Being(b)):
                return a == nil && b == nil || arrayEquals(arr1: a, arr2: b)
            case let (.arrayArray_Optional__AnyHashable(a), .arrayArray_Optional__AnyHashable(b)):
                return a == b
            case let (.optionalArray_Array__Optional___AnyHashable(a), .optionalArray_Array__Optional___AnyHashable(b)):
                return a == nil && b == nil || a == b
            case let (.arrayOptional_Array__Optional___AnyHashable(a), .arrayOptional_Array__Optional___AnyHashable(b)):
                return a == b
            case let (.optionalArray_Optional__Array___Optional____AnyHashable(a), .optionalArray_Optional__Array___Optional____AnyHashable(b)):
                return a == nil && b == nil || a == b
            default:
                return false
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as [any pkl_swift_lib1.Being]:
                self = NestListings.arraypkl_swift_lib1Being(decoded)
            case let decoded as [any pkl_swift_lib1.Being]?:
                self = NestListings.optionalArray_pkl_swift_lib1Being(decoded)
            case let decoded as [(any pkl_swift_lib1.Being)?]:
                self = NestListings.arrayOptional_pkl_swift_lib1Being(decoded)
            case let decoded as [(any pkl_swift_lib1.Being)?]?:
                self = NestListings.optionalArray_Optional__pkl_swift_lib1Being(decoded)
            case let decoded as [[AnyHashable?]]:
                self = NestListings.arrayArray_Optional__AnyHashable(decoded)
            case let decoded as [[AnyHashable?]]?:
                self = NestListings.optionalArray_Array__Optional___AnyHashable(decoded)
            case let decoded as [[AnyHashable?]?]:
                self = NestListings.arrayOptional_Array__Optional___AnyHashable(decoded)
            case let decoded as [[AnyHashable?]?]?:
                self = NestListings.optionalArray_Optional__Array___Optional____AnyHashable(decoded)
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
            case let .arraypkl_swift_lib1Being(value):
                hasher.combine("arraypkl_swift_lib1Being")
                for x in value {
                    hasher.combine(x)
                }
            case let .optionalArray_pkl_swift_lib1Being(value):
                hasher.combine("optionalArray_pkl_swift_lib1Being")
                if let value {
                    for x in value {
                        hasher.combine(x)
                    }
                }
            case let .arrayOptional_pkl_swift_lib1Being(value):
                hasher.combine("arrayOptional_pkl_swift_lib1Being")
                for x in value {
                    if let x {
                        hasher.combine(x)
                    }
                }
            case let .optionalArray_Optional__pkl_swift_lib1Being(value):
                hasher.combine("optionalArray_Optional__pkl_swift_lib1Being")
                if let value {
                    for x in value {
                        if let x {
                            hasher.combine(x)
                        }
                    }
                }
            case let .arrayArray_Optional__AnyHashable(value):
                hasher.combine("arrayArray_Optional__AnyHashable")
                for x in value {
                    for x in x {
                        if let x {
                            hasher.combine(x)
                        }
                    }
                }
            case let .optionalArray_Array__Optional___AnyHashable(value):
                hasher.combine("optionalArray_Array__Optional___AnyHashable")
                if let value {
                    for x in value {
                        for x in x {
                            if let x {
                                hasher.combine(x)
                            }
                        }
                    }
                }
            case let .arrayOptional_Array__Optional___AnyHashable(value):
                hasher.combine("arrayOptional_Array__Optional___AnyHashable")
                for x in value {
                    if let x {
                        for x in x {
                            if let x {
                                hasher.combine(x)
                            }
                        }
                    }
                }
            case let .optionalArray_Optional__Array___Optional____AnyHashable(value):
                hasher.combine("optionalArray_Optional__Array___Optional____AnyHashable")
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

    public enum NestMappings: Decodable, Hashable {
        case dictionaryOptional_Stringpkl_swift_lib1Being([String?: any pkl_swift_lib1.Being])
        case optionalDictionary_Optional__String_pkl_swift_lib1Being([String?: any pkl_swift_lib1.Being]?)
        case dictionaryOptional_StringOptional_pkl_swift_lib1Being([String?: (any pkl_swift_lib1.Being)?])
        case optionalDictionary_Optional__String_Optional__pkl_swift_lib1Being([String?: (any pkl_swift_lib1.Being)?]?)
        case dictionaryOptional_StringDictionary_Optional__AnyHashable_Optional__AnyHashable([String?: [AnyHashable?: AnyHashable?]])
        case optionalDictionary_Optional__String_Dictionary__Optional___AnyHashable__Optional___AnyHashable([String?: [AnyHashable?: AnyHashable?]]?)
        case dictionaryOptional_StringOptional_Dictionary__Optional___AnyHashable__Optional___AnyHashable([String?: [AnyHashable?: AnyHashable?]?])
        case optionalDictionary_Optional__String_Optional__Dictionary___Optional____AnyHashable___Optional____AnyHashable([String?: [AnyHashable?: AnyHashable?]?]?)

        public static func ==(lhs: NestMappings, rhs: NestMappings) -> Bool {
            switch (lhs, rhs) {
            case let (.dictionaryOptional_Stringpkl_swift_lib1Being(a), .dictionaryOptional_Stringpkl_swift_lib1Being(b)):
                return mapEquals(map1: a, map2: b)
            case let (.optionalDictionary_Optional__String_pkl_swift_lib1Being(a), .optionalDictionary_Optional__String_pkl_swift_lib1Being(b)):
                return a == nil && b == nil || mapEquals(map1: a, map2: b)
            case let (.dictionaryOptional_StringOptional_pkl_swift_lib1Being(a), .dictionaryOptional_StringOptional_pkl_swift_lib1Being(b)):
                return mapEquals(map1: a, map2: b)
            case let (.optionalDictionary_Optional__String_Optional__pkl_swift_lib1Being(a), .optionalDictionary_Optional__String_Optional__pkl_swift_lib1Being(b)):
                return a == nil && b == nil || mapEquals(map1: a, map2: b)
            case let (.dictionaryOptional_StringDictionary_Optional__AnyHashable_Optional__AnyHashable(a), .dictionaryOptional_StringDictionary_Optional__AnyHashable_Optional__AnyHashable(b)):
                return a == b
            case let (.optionalDictionary_Optional__String_Dictionary__Optional___AnyHashable__Optional___AnyHashable(a), .optionalDictionary_Optional__String_Dictionary__Optional___AnyHashable__Optional___AnyHashable(b)):
                return a == nil && b == nil || a == b
            case let (.dictionaryOptional_StringOptional_Dictionary__Optional___AnyHashable__Optional___AnyHashable(a), .dictionaryOptional_StringOptional_Dictionary__Optional___AnyHashable__Optional___AnyHashable(b)):
                return a == b
            case let (.optionalDictionary_Optional__String_Optional__Dictionary___Optional____AnyHashable___Optional____AnyHashable(a), .optionalDictionary_Optional__String_Optional__Dictionary___Optional____AnyHashable___Optional____AnyHashable(b)):
                return a == nil && b == nil || a == b
            default:
                return false
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(PklSwift.PklAny.self).value
            switch value?.base {
            case let decoded as [String?: any pkl_swift_lib1.Being]:
                self = NestMappings.dictionaryOptional_Stringpkl_swift_lib1Being(decoded)
            case let decoded as [String?: any pkl_swift_lib1.Being]?:
                self = NestMappings.optionalDictionary_Optional__String_pkl_swift_lib1Being(decoded)
            case let decoded as [String?: (any pkl_swift_lib1.Being)?]:
                self = NestMappings.dictionaryOptional_StringOptional_pkl_swift_lib1Being(decoded)
            case let decoded as [String?: (any pkl_swift_lib1.Being)?]?:
                self = NestMappings.optionalDictionary_Optional__String_Optional__pkl_swift_lib1Being(decoded)
            case let decoded as [String?: [AnyHashable?: AnyHashable?]]:
                self = NestMappings.dictionaryOptional_StringDictionary_Optional__AnyHashable_Optional__AnyHashable(decoded)
            case let decoded as [String?: [AnyHashable?: AnyHashable?]]?:
                self = NestMappings.optionalDictionary_Optional__String_Dictionary__Optional___AnyHashable__Optional___AnyHashable(decoded)
            case let decoded as [String?: [AnyHashable?: AnyHashable?]?]:
                self = NestMappings.dictionaryOptional_StringOptional_Dictionary__Optional___AnyHashable__Optional___AnyHashable(decoded)
            case let decoded as [String?: [AnyHashable?: AnyHashable?]?]?:
                self = NestMappings.optionalDictionary_Optional__String_Optional__Dictionary___Optional____AnyHashable___Optional____AnyHashable(decoded)
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
            case let .dictionaryOptional_Stringpkl_swift_lib1Being(value):
                hasher.combine("dictionaryOptional_Stringpkl_swift_lib1Being")
                for (k, v) in value {
                    if let k {
                        hasher.combine(k)
                    }
                    hasher.combine(v)
                }
            case let .optionalDictionary_Optional__String_pkl_swift_lib1Being(value):
                hasher.combine("optionalDictionary_Optional__String_pkl_swift_lib1Being")
                if let value {
                    for (k, v) in value {
                        if let k {
                            hasher.combine(k)
                        }
                        hasher.combine(v)
                    }
                }
            case let .dictionaryOptional_StringOptional_pkl_swift_lib1Being(value):
                hasher.combine("dictionaryOptional_StringOptional_pkl_swift_lib1Being")
                for (k, v) in value {
                    if let k {
                        hasher.combine(k)
                    }
                    if let v {
                        hasher.combine(v)
                    }
                }
            case let .optionalDictionary_Optional__String_Optional__pkl_swift_lib1Being(value):
                hasher.combine("optionalDictionary_Optional__String_Optional__pkl_swift_lib1Being")
                if let value {
                    for (k, v) in value {
                        if let k {
                            hasher.combine(k)
                        }
                        if let v {
                            hasher.combine(v)
                        }
                    }
                }
            case let .dictionaryOptional_StringDictionary_Optional__AnyHashable_Optional__AnyHashable(value):
                hasher.combine("dictionaryOptional_StringDictionary_Optional__AnyHashable_Optional__AnyHashable")
                for (k, v) in value {
                    if let k {
                        hasher.combine(k)
                    }
                    for (k, v) in v {
                        if let k {
                            hasher.combine(k)
                        }
                        if let v {
                            hasher.combine(v)
                        }
                    }
                }
            case let .optionalDictionary_Optional__String_Dictionary__Optional___AnyHashable__Optional___AnyHashable(value):
                hasher.combine("optionalDictionary_Optional__String_Dictionary__Optional___AnyHashable__Optional___AnyHashable")
                if let value {
                    for (k, v) in value {
                        if let k {
                            hasher.combine(k)
                        }
                        for (k, v) in v {
                            if let k {
                                hasher.combine(k)
                            }
                            if let v {
                                hasher.combine(v)
                            }
                        }
                    }
                }
            case let .dictionaryOptional_StringOptional_Dictionary__Optional___AnyHashable__Optional___AnyHashable(value):
                hasher.combine("dictionaryOptional_StringOptional_Dictionary__Optional___AnyHashable__Optional___AnyHashable")
                for (k, v) in value {
                    if let k {
                        hasher.combine(k)
                    }
                    if let v {
                        for (k, v) in v {
                            if let k {
                                hasher.combine(k)
                            }
                            if let v {
                                hasher.combine(v)
                            }
                        }
                    }
                }
            case let .optionalDictionary_Optional__String_Optional__Dictionary___Optional____AnyHashable___Optional____AnyHashable(value):
                hasher.combine("optionalDictionary_Optional__String_Optional__Dictionary___Optional____AnyHashable___Optional____AnyHashable")
                if let value {
                    for (k, v) in value {
                        if let k {
                            hasher.combine(k)
                        }
                        if let v {
                            for (k, v) in v {
                                if let k {
                                    hasher.combine(k)
                                }
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

    public struct Module: PklRegisteredType, Decodable, Hashable {
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

        public var nestMapping1: [String?: [AnyHashable?: AnyHashable?]]

        public var nestMapping2: [String?: [AnyHashable?: AnyHashable?]]?

        public var nestMapping3: [String?: [AnyHashable?: AnyHashable?]?]

        public var nestMapping4: [String?: [AnyHashable?: AnyHashable?]?]?

        public var nestMappings: NestMappings

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
            nestMapping1: [String?: [AnyHashable?: AnyHashable?]],
            nestMapping2: [String?: [AnyHashable?: AnyHashable?]]?,
            nestMapping3: [String?: [AnyHashable?: AnyHashable?]?],
            nestMapping4: [String?: [AnyHashable?: AnyHashable?]?]?,
            nestMappings: NestMappings
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
            self.nestMapping1 = nestMapping1
            self.nestMapping2 = nestMapping2
            self.nestMapping3 = nestMapping3
            self.nestMapping4 = nestMapping4
            self.nestMappings = nestMappings
        }

        public static func ==(lhs: Module, rhs: Module) -> Bool {
            arrayEquals(arr1: lhs.beings, arr2: rhs.beings)
            && lhs.beings2 == nil && rhs.beings2 == nil || arrayEquals(arr1: lhs.beings2, arr2: rhs.beings2)
            && arrayEquals(arr1: lhs.beings3, arr2: rhs.beings3)
            && lhs.beings4 == nil && rhs.beings4 == nil || arrayEquals(arr1: lhs.beings4, arr2: rhs.beings4)
            && lhs.dogs == nil && rhs.dogs == nil || arrayEquals(arr1: lhs.dogs, arr2: rhs.dogs)
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
            && lhs.nestMapping1 == rhs.nestMapping1
            && lhs.nestMapping2 == nil && rhs.nestMapping2 == nil || lhs.nestMapping2 == rhs.nestMapping2
            && lhs.nestMapping3 == rhs.nestMapping3
            && lhs.nestMapping4 == nil && rhs.nestMapping4 == nil || lhs.nestMapping4 == rhs.nestMapping4
            && lhs.nestMappings == rhs.nestMappings
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
            hasher.combine(nestMapping1)
            hasher.combine(nestMapping2)
            hasher.combine(nestMapping3)
            hasher.combine(nestMapping4)
            hasher.combine(nestMappings)
        }

        public init(from decoder: Decoder) throws {
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
            let nestMapping1 = try dec.decode([String?: [PklSwift.PklAny: PklSwift.PklAny]].self, forKey: PklCodingKey(string: "nestMapping1"))
                .mapValues {
                    $0.mapValues {
                        $0.value
                    }
                }
            let nestMapping2 = try dec.decode([String?: [PklSwift.PklAny: PklSwift.PklAny]]?.self, forKey: PklCodingKey(string: "nestMapping2"))?
                .mapValues {
                    $0.mapValues {
                        $0.value
                    }
                }
            let nestMapping3 = try dec.decode([String?: [PklSwift.PklAny: PklSwift.PklAny]?].self, forKey: PklCodingKey(string: "nestMapping3"))
                .mapValues {
                    $0?.mapValues {
                        $0.value
                    }
                }
            let nestMapping4 = try dec.decode([String?: [PklSwift.PklAny: PklSwift.PklAny]?]?.self, forKey: PklCodingKey(string: "nestMapping4"))?
                .mapValues {
                    $0?.mapValues {
                        $0.value
                    }
                }
            let nestMappings = try dec.decode(NestMappings.self, forKey: PklCodingKey(string: "nestMappings"))
            self = Module(beings: beings, beings2: beings2, beings3: beings3, beings4: beings4, dogs: dogs, rex: rex, moreBeings: moreBeings, moreBeings2: moreBeings2, moreBeings3: moreBeings3, moreBeings4: moreBeings4, nestListing1: nestListing1, nestListing2: nestListing2, nestListing3: nestListing3, nestListing4: nestListing4, nestListings: nestListings, nestMapping1: nestMapping1, nestMapping2: nestMapping2, nestMapping3: nestMapping3, nestMapping4: nestMapping4, nestMappings: nestMappings)
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

        public init(from decoder: Decoder) throws {
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