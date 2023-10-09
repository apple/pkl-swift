// ===----------------------------------------------------------------------===//
// Copyright © 2023 Apple Inc. and the Pkl project authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//	https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ===----------------------------------------------------------------------===//

import PklSwift
import XCTest

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

    func testEvaluateApiTypes() async throws {
        let result = try await ApiTypes.loadFrom(
            evaluator: self.evaluator,
            source: .path("\(#filePath)/../Fixtures/ApiTypes.pkl")
        )
        XCTAssertEqual(
            result,
            ApiTypes.Module(
                res1: Pair(42, "Hello"),
                res2: .hours(10),
                res3: .gibibytes(1.2345)
            )
        )
    }

    typealias Poly = pkl_swift_example_Poly

    func testPolymorphicTypes() async throws {
        let result = try await Poly.loadFrom(
            evaluator: self.evaluator,
            source: .path("\(#filePath)/../Fixtures/Poly.pkl")
        )
        XCTAssertEqual(
            result,
            Poly.Module(
                beings: [
                    Poly.AnimalImpl(name: "Lion", exists: true),
                    Poly.Dog(barks: true, hates: nil, name: "Ruuf", exists: true),
                    Poly.Bird(name: "Duck", flies: false, exists: false),
                ],
                rex: Poly.Dog(barks: false, hates: nil, name: "Rex", exists: true),
                moreBeings: [
                    "duck": Poly.Bird(name: "Ducky", flies: true, exists: true),
                    "dog": Poly.Dog(
                        barks: false,
                        hates: Poly.Dog(barks: false, hates: nil, name: "Rex", exists: true),
                        name: "TRex",
                        exists: true
                    ),
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
            animalOrString2: .string("Zebra")
        ))
    }
}
