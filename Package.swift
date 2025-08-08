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
            url: "https://github.com/loodos/enliq-linkify-ios-sdk/releases/download/0.0.1/eiqlinkify.xcframework.zip",
            checksum: "bcc2a4a5d03951c33dc5adfc11a5cea74af4ea8e27a2919605e7d7041e6bf21e"
        )
    ]
)
