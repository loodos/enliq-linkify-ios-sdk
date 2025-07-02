// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "EIQLinkify",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "EIQLinkify",
            targets: ["EIQLinkify"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "EIQLinkify",
            url: "https://github.com/loodos/enliq-linkify-ios-sdk/releases/download/1.0.0/eiqlinkify.xcframework.zip",
            checksum: "a11bf7bd037eec83c15e6ed283d55a8343787b9be19014ea013ad5f720f0b1e8"
        )
    ]
)
