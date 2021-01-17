// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "UltraDrawerView",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "UltraDrawerView",
            targets: ["UltraDrawerView"]),
    ],
    targets: [
        .target(
            name: "UltraDrawerViewObjCUtils",
            dependencies: [],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit")
            ]),
        .target(
            name: "UltraDrawerView",
            dependencies: ["UltraDrawerViewObjCUtils"]),
        .testTarget(
            name: "UltraDrawerViewTests",
            dependencies: ["UltraDrawerView"]),
    ],
    swiftLanguageVersions: [.v5]
)
