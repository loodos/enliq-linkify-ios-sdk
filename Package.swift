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
            checksum: "a13205a3a5387baf7b740be22760b8a10de7acc7f87f38dc27601784662e969e"
        )
    ]
)
