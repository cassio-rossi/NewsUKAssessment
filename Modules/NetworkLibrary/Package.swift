// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkLibrary",
	defaultLocalization: "en",
	platforms: [.iOS(.v17)],
    products: [
        .library(name: "NetworkLibrary", targets: ["NetworkLibrary"])
    ],
    dependencies: [],
    targets: [
        .target(name: "NetworkLibrary",
				dependencies: [],
				resources: [.process("Resources")]),
        .testTarget(name: "NetworkLibraryTests",
                    dependencies: ["NetworkLibrary"],
                    resources: [.process("Resources")])
    ]
)
