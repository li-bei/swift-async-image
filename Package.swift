// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "swift-async-image",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "AsyncImage", targets: ["AsyncImage"]),
    ],
    dependencies: [
        .package(path: "../swift-file-downloader"),
    ],
    targets: [
        .target(
            name: "AsyncImage",
            dependencies: [
                .product(name: "FileDownloader", package: "swift-file-downloader"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=complete"),
                .enableUpcomingFeature("ConciseMagicFile")
            ]
        ),
    ]
)
