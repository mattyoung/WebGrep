// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebGrep",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", .upToNextMajor(from: "2.6.1")),
        // Spinner already has dependency to an older version of Rainbow
//        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.0.1")),
//        .package(url: "https://github.com/pakLebah/ANSITerminal.git", .upToNextMajor(from: "0.0.3")),
//        .package(url: "https://github.com/dominicegginton/Spinner", from: "1.0.0"),
        .package(url: "https://github.com/mattyoung/spinner.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "webgrep",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
//                .product(name: "Rainbow", package: "Rainbow"),
//                .product(name: "ANSITerminal", package: "ANSITerminal")
                .product(name: "Spinner", package: "Spinner"),
            ]
        ),
    ]
)
