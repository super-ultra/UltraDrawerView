// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "UltraDrawerView",
    platforms: [
        .iOS(.v13)
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
    swiftLanguageModes: [.v6]
)
