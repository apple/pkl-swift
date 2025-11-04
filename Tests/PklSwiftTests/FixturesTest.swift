//===----------------------------------------------------------------------===//
// Copyright © 2024-2025 Apple Inc. and the Pkl project authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//===----------------------------------------------------------------------===//

@testable import PklSwift
import SemanticVersion
import XCTest

#if os(macOS) || os(Linux) || os(Windows)
class FixturesTest: XCTestCase {
    var manager: EvaluatorManager!
    var evaluator: Evaluator!

    override func setUp() async throws {
        self.manager = EvaluatorManager()
        self.evaluator = try await self.manager.newEvaluator(options: .preconfigured)
    }

    override func tearDown() async throws {
        await self.manager.close()
    }

    func testEvaluateClasses() async throws {
        let result = try await Classes.loadFrom(
            evaluator: self.evaluator,
            source: .path("\(#filePath)/../Fixtures/Classes.pkl")
        )
        XCTAssertEqual(
            result,
            Classes.Module(
                animals: [
                    Classes.Animal(name: "Uni"),
                    Classes.Animal(name: "Wally"),
                    Classes.Animal(name: "Mouse"),
                ]
            )
        )
    }

    func testEvaluateCollections() async throws {
        let result = try await Collections.loadFrom(
            evaluator: self.evaluator,
            source: .path("\(#filePath)/../Fixtures/Collections.pkl")
        )
        XCTAssertEqual(
            result,
            Collections.Module(
                res1: [1, 2, 3],
                res2: [2, 3, 4],
                res3: [[1], [2], [3]],
                res4: [[1], [2], [3]],
                res5: [1: true, 2: false],
                res6: [1: [1: true], 2: [2: true], 3: [3: true]],
                res7: [1: true, 2: false],
                res8: [1: [1: true], 2: [2: false]],
                res9: ["one", "two", "three"],
                res10: [1, 2, 3]
            )
        )
    }

    func testEvaluateCollections2() async throws {
        let version = try await SemanticVersion(EvaluatorManager().getVersion())!
        if version < pklVersion0_29 {
            throw XCTSkip("Bytes() is not available")
        }
        let result = try await Collections2.loadFrom(
            evaluator: self.evaluator,
            source: .path("\(#filePath)/../Fixtures/Collections2.pkl")
        )
        XCTAssertEqual(
            result,
            Collections2.Module(res: [1, 2, 3, 255])
        )
    }

    func testEvaluateApiTypes() async throws {
        let inputPath = "\(#filePath)/../Fixtures/ApiTypes.pkl"
        let result = try await ApiTypes.loadFrom(
            evaluator: self.evaluator,
            source: .path(inputPath)
        )

        let stringClass: Class
        let baseModuleClass: Class
        let uint8TypeAlias: TypeAlias
        let fooClass: Class
        let barTypeAlias: TypeAlias
        let version = try await SemanticVersion(EvaluatorManager().getVersion())!
        if version < pklVersion0_30 {
            stringClass = Class(moduleUri: "", name: "")
            baseModuleClass = Class(moduleUri: "", name: "")
            uint8TypeAlias = TypeAlias(moduleUri: "", name: "")
            fooClass = Class(moduleUri: "", name: "")
            barTypeAlias = TypeAlias(moduleUri: "", name: "")
        } else {
            let inputModuleURI = URL(filePath: inputPath).standardizedFileURL.absoluteString.replacing("file:///", with: "file:/")
            stringClass = Class(moduleUri: "pkl:base", name: "String")
            baseModuleClass = Class(moduleUri: "pkl:base", name: "ModuleClass")
            uint8TypeAlias = TypeAlias(moduleUri: "pkl:base", name: "UInt8")
            fooClass = Class(moduleUri: inputModuleURI, name: "ApiTypes#Foo")
            barTypeAlias = TypeAlias(moduleUri: inputModuleURI, name: "ApiTypes#Bar")
        }

        XCTAssertEqual(
            result,
            ApiTypes.Module(
                res1: .hours(10),
                res2: .gibibytes(1.2345),
                stringClass: stringClass,
                baseModuleClass: baseModuleClass,
                uint8TypeAlias: uint8TypeAlias,
                fooClass: fooClass,
                barTypeAlias: barTypeAlias
            )
        )
    }

    typealias Poly = pkl_swift_example_Poly

    func testPolymorphicTypes() async throws {
        let result = try await Poly.loadFrom(
            evaluator: self.evaluator,
            source: .path("\(#filePath)/../Fixtures/Poly.pkl")
        )
        let being: [any pkl_swift_lib1.Being] = [
            Poly.AnimalImpl(name: "Lion", exists: true),
            Poly.Dog(barks: true, hates: nil, name: "Ruuf", exists: true),
            Poly.Bird(name: "Duck", flies: false, exists: false),
        ]
        let moreBeings: [String: any pkl_swift_lib1.Being] = [
            "duck": Poly.Bird(name: "Ducky", flies: true, exists: true),
            "dog": Poly.Dog(
                barks: false,
                hates: Poly.Dog(barks: false, hates: nil, name: "Rex", exists: true),
                name: "TRex",
                exists: true
            ),
        ]
        XCTAssertEqual(
            result,
            Poly.Module(
                beings: being,
                beings2: being,
                beings3: being,
                beings4: being,
                dogs: nil,
                rex: Poly.Dog(barks: false, hates: nil, name: "Rex", exists: true),
                moreBeings: moreBeings,
                moreBeings2: moreBeings,
                moreBeings3: moreBeings,
                moreBeings4: moreBeings,
                nestListing1: [],
                nestListing2: nil,
                nestListing3: [],
                nestListing4: nil,
                nestListings: .listingpkl_swift_lib1Being([]),
                nestList1: [],
                nestList2: nil,
                nestList3: [],
                nestList4: nil,
                nestLists: .listpkl_swift_lib1Being([]),
                nestMapping1: [:],
                nestMapping2: nil,
                nestMapping3: [:],
                nestMapping4: nil,
                nestMappingObj1: [:],
                nestMappingObj2: nil,
                nestMappingObj3: [:],
                nestMappingObj4: nil,
                nestMappings: .mapping_pkl_swift_lib1Being_OptionalString([:]),
                nestMap1: [:],
                nestMap2: nil,
                nestMap3: [:],
                nestMap4: nil,
                nestMapObj1: [:],
                nestMapObj2: nil,
                nestMapObj3: [:],
                nestMapObj4: nil,
                nestMaps: .map_pkl_swift_lib1Being_OptionalString([:]),
                sameResultType: .listingString([]),
                foosListing: [
                    Poly.Foo(name: "baz", bars: nil),
                    Poly.Foo(name: "quz", bars: ["a", "b"]),
                ],
                foosMapping: [
                    "hello": Poly.Foo(name: "baz", bars: nil),
                    "world": Poly.Foo(name: "quz", bars: ["a", "b"]),
                ]
            )
        )
    }

    func testPolymorphicModules() async throws {
        let result = try await ExtendedModule.loadFrom(
            evaluator: self.evaluator,
            source: .path("\(#filePath)/../Fixtures/ExtendedModule.pkl")
        )
        XCTAssertEqual(
            result,
            ExtendedModule.Module(foo: "foo", bar: 10)
        )
    }

    func testAnyType() async throws {
        let result = try await AnyType.loadFrom(
            evaluator: self.evaluator,
            source: .path("\(#filePath)/../Fixtures/AnyType.pkl")
        )
        XCTAssertEqual(
            result,
            AnyType.Module(
                bird: AnyType.Bird(species: "Owl"),
                primitive: "foo",
                primitive2: 12,
                array: [1, 2],
                set: Set([5, 6]),
                mapping: ["1": 12, 12: "1"] as [AnyHashable: AnyHashable],
                nullable: nil,
                duration: Duration(5, unit: DurationUnit.min),
                dataSize: DataSize(10, unit: DataSizeUnit.mb)
            )
        )
    }

    func testUnionTypes() async throws {
        let result = try await UnionTypes.loadFrom(
            evaluator: self.evaluator,
            source: .path("\(#filePath)/../Fixtures/UnionTypes.pkl")
        )
        XCTAssertEqual(result, .init(
            fruit1: .banana(.init(isRipe: true)),
            fruit2: .grape(.init(isUsedForWine: true)),
            fruit3: .apple(.init(isRed: false)),
            city1: .sanFrancisco,
            city2: .tokyo,
            city3: .zurich,
            city4: .london,
            animal1: .zebra(UnionTypes.Zebra(name: "Zebra")),
            animal2: .donkey(UnionTypes.Donkey(name: "Donkey")),
            animalOrString1: .animal(UnionTypes.Zebra(name: "Zebra")),
            animalOrString2: .string("Zebra"),
            intOrFloat1: .float64(5.0),
            intOrFloat2: .float64(5.5),
            intOrFloat3: .int(128),
            config: [.dev : "Imaginary Service Company (ISC) configuration"],
            animalOrShape1: .animal(UnionTypes.Donkey(name: "Donkey")),
            animalOrShape2: .shape(UnionTypes.Square(corners: 4)),
            numbers1: .int8(5),
            numbers2: .int16(128),
            numbers3: .int32(32768),
            numbers4: .int(Int.max)
        ))
    }
}
#endif
