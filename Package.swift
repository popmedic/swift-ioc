// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IoC",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "IoC",
            targets: ["IoC"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "IoC",
            dependencies: []),
        .testTarget(
            name: "IoCTests",
            dependencies: ["IoC"]),
    ]
)
