// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Libraries",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],

    products: [
        .library(name: "Logger", targets: ["LoggerLibrary"])
    ],

    targets: [
        .target(name: "LoggerLibrary"),
        .testTarget(name: "LoggerLibraryTests",
                    dependencies: ["LoggerLibrary"])
    ]
)
