// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "pkl-swift",
    platforms: [
        // required because of `Duration` API
        .macOS(.v13)
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
    ],
    targets: [
        .target(
            name: "PklSwift",
            dependencies: ["MessagePack", "PklSwiftInternals"]
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
