// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Yumi",
    products: [
        .library(
            name: "Yumi",
            targets: ["Yumi"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-collections", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", .upToNextMinor(from: "0.4.0")),
        // Plugins
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Yumi",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            ]),
        .testTarget(
            name: "YumiTests",
            dependencies: ["Yumi"]),
    ]
)
