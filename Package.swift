// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSDL2Testt",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "SwiftSDL2Testt",
            targets: ["SwiftSDL2Testt"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(path: "../SDL"),
        .package(name: "GL", url: "https://github.com/kelvin13/swift-opengl.git", .branch("master")),
        .package(url: "https://github.com/mxcl/Path.swift.git", .branch("master")),
        .package(name: "ImGui", url: "https://github.com/ctreffs/SwiftImGui.git", from: "1.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftSDL2Testt",
            dependencies: ["SDL", "GL", .product(name: "Path", package: "Path.swift")]),
        .testTarget(
            name: "SwiftSDL2TesttTests",
            dependencies: ["SwiftSDL2Testt"]),
    ]
)
