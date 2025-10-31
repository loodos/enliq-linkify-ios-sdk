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
            url: "https://github.com/loodos/enliq-linkify-ios-sdk/releases/download/v1.1.6/eiqlinkify.xcframework.zip",
            checksum: "a3d48a89fb5663ed88bdb56eee731a6164d1031ed99e2bf723b71c6baec616d1"
        )
    ]
)
