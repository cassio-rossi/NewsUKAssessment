// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnalyticsLibrary",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AnalyticsLibrary", targets: ["AnalyticsLibrary"])
    ],
    dependencies: [
        .package(name: "Logger", path: "../LoggerLibrary")
    ],
    targets: [
        .target(name: "AnalyticsLibrary",
                dependencies: ["Logger"]),
        .testTarget(name: "AnalyticsLibraryTests",
                    dependencies: ["AnalyticsLibrary"])
    ]
)
