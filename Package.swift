// swift-tools-version: 5.9
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

import PackageDescription

let package = Package(
    name: "pkl-swift",
    platforms: [
        // required because of `Duration` API
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "MessagePack",
            targets: ["MessagePack"]
        ),
        .library(
            name: "PklSwift",
            targets: ["PklSwift"]
        ),
        .executable(
            name: "pkl-gen-swift",
            targets: ["pkl-gen-swift"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-system", from: "1.2.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.3"),
        .package(url: "https://github.com/SwiftPackageIndex/SemanticVersion", from: "0.4.0"),
        // to enable `swift package generate-documentation --target PklSwift`
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
        // to enable `swift package plugin --allow-writing-to-package-directory swiftformat`
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.55.0"),
    ],
    targets: [
        .target(
            name: "PklSwift",
            dependencies: ["MessagePack", "PklSwiftInternals", "SemanticVersion"]
        ),
        .target(
            name: "PklSwiftInternals"
        ),
        .target(
            name: "MessagePack",
            dependencies: [
                .product(name: "SystemPackage", package: "swift-system"),
            ]
        ),
        .executableTarget(
            name: "pkl-gen-swift",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "PklSwift",
            ],
            resources: [.embedInCode("Resources/VERSION.txt")]
        ),
        .executableTarget(
            name: "test-external-reader",
            dependencies: ["PklSwift"]
        ),
        .testTarget(
            name: "PklSwiftTests",
            dependencies: [
                "PklSwift",
            ],
            exclude: [
                "Fixtures/Classes.pkl",
                "Fixtures/UnionTypes.pkl",
                "Fixtures/AnyType.pkl",
                "Fixtures/lib1.pkl",
                "Fixtures/ExtendedModule.pkl",
                "Fixtures/OpenModule.pkl",
                "Fixtures/Collections.pkl",
                "Fixtures/Poly.pkl",
                "Fixtures/ApiTypes.pkl",
            ]
        ),
        .testTarget(
            name: "MessagePackTests",
            dependencies: [
                "MessagePack",
            ]
        ),
    ],
    cxxLanguageStandard: .cxx20
)
