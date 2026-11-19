// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MealMateCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "MealMateCore", targets: ["MealMateCore"])],
    targets: [
        .target(name: "MealMateCore"),
        .testTarget(name: "MealMateCoreTests", dependencies: ["MealMateCore"])
    ]
)
