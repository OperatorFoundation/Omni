// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Omni",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "Omni",
            targets: ["Omni"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.5.4"),
        
        .package(url: "https://github.com/OperatorFoundation/Antiphony", from: "1.0.5"),
        .package(url: "https://github.com/OperatorFoundation/Gardener", from: "0.1.2"),
        .package(url: "https://github.com/OperatorFoundation/KeychainTypes", from: "1.0.2"),
        .package(url: "https://github.com/OperatorFoundation/ReplicantSwift", from: "2.0.2"),
        .package(url: "https://github.com/OperatorFoundation/TransmissionAsync", from: "0.1.5"),
    ],
    targets: [
        .target(
            name: "Omni",
            dependencies: [
                "Antiphony",
                "KeychainTypes",
                "ReplicantSwift",
                "TransmissionAsync",
                .product(name: "Logging", package: "swift-log"),
            ]),
        .testTarget(
            name: "OmniTests",
            dependencies: ["Omni"]),
    ],
    swiftLanguageVersions: [.v5]
)
