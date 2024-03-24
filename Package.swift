// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SimpleSQLite",
    products: [
        .library(
            name: "SimpleSQLite",
            targets: ["SimpleSQLite"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SimpleSQLite",
            dependencies: []),
        .testTarget(
            name: "SimpleSQLiteTests",
            dependencies: ["SimpleSQLite"]),
    ]
)
