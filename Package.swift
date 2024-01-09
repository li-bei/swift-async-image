// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-async-image",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(name: "AsyncImage", targets: ["AsyncImage"]),
    ],
    targets: [
        .target(
            name: "AsyncImage",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=complete"),
                .enableUpcomingFeature("ConciseMagicFile")
            ]
        ),
    ]
)
