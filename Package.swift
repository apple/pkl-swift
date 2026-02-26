// swift-tools-version: 6.0
//===----------------------------------------------------------------------===//
// Copyright © 2024-2026 Apple Inc. and the Pkl project authors. All rights reserved.
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
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
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
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-system", from: "1.2.1"),
        .package(url: "https://github.com/SwiftPackageIndex/SemanticVersion", from: "0.4.0"),
        // to enable `swift package generate-documentation --target PklSwift`
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
        // to enable `swift package plugin --allow-writing-to-package-directory swiftformat`
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.55.0"),
    ],
    targets: [
        .target(
            name: "PklSwift",
            dependencies: ["MessagePack", "PklSwiftInternals", "SemanticVersion"],
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")],
        ),
        .target(
            name: "PklSwiftInternals",
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
        ),
        .target(
            name: "MessagePack",
            dependencies: [
                .product(name: "SystemPackage", package: "swift-system"),
            ],
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
        ),
        .executableTarget(
            name: "test-external-reader",
            dependencies: ["PklSwift"],
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
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
                "Fixtures/Collections2.pkl",
                "Fixtures/Poly.pkl",
                "Fixtures/ApiTypes.pkl",
                "Fixtures/Collections2.pkl",
                "Fixtures/UnusedClass.pkl",
                "Fixtures/Imports/UnusedClassDefs.pkl",
            ],
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "MessagePackTests",
            dependencies: [
                "MessagePack",
            ],
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
        ),
    ],
    swiftLanguageModes: [.v5, .v6],
    cxxLanguageStandard: .cxx20
)
