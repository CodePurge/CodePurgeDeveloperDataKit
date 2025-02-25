// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodePurgeDeveloperDataKit",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CodePurgeDeveloperDataKit",
            targets: ["CodePurgeDeveloperDataKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nikolainobadi/NnTestKit", from: "1.1.0"),
        .package(url: "https://github.com/CodePurge/CodePurgeKit.git", branch: "main")
    ],
    targets: [
        .target(
            name: "CodePurgeDeveloperDataKit",
            dependencies: [
                "CodePurgeKit"
            ]
        ),
        .testTarget(
            name: "CodePurgeDeveloperDataKitTests",
            dependencies: [
                "CodePurgeDeveloperDataKit",
                .product(name: "NnTestHelpers", package: "NnTestKit")
            ]
        )
    ]
)
