// swift-tools-version: 5.9
//
// EIQLinkify iOS SDK — v1.2.0
// Bu dosya otomatik üretilir; elle düzenlemeyin.

import PackageDescription

let package = Package(
    name: "EIQLinkify",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "EIQLinkify", targets: ["EIQLinkify"]),
    ],
    targets: [
        .binaryTarget(
            name: "EIQLinkify",
            url: "https://github.com/loodos/enliq-linkify-ios-sdk/releases/download/v1.2.0/EIQLinkify.xcframework.zip",
            checksum: "73bc1ee58dc6dcabafd82c0cb153d900a6f5dc6c7ae3f825bb0bec0af0d8e1e4"
        ),
    ]
)
