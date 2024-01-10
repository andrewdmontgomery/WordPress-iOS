// swift-tools-version: 5.8

import PackageDescription

let jetpackStatsWidgetsCoreName = "JetpackStatsWidgetsCore"
let designSystemName = "DesignSystem"
let gravatar = "Gravatar"

let package = Package(
    name: "Modules",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: jetpackStatsWidgetsCoreName, targets: [jetpackStatsWidgetsCoreName]),
        .library(name: designSystemName, targets: [designSystemName]),
        .library(name: gravatar, targets: [gravatar])
    ],
    targets: [
        .target(name: jetpackStatsWidgetsCoreName),
        .testTarget(
            name: "\(jetpackStatsWidgetsCoreName)Tests",
            dependencies: [.target(name: jetpackStatsWidgetsCoreName)]
        ),
        .target(name: designSystemName),
        .target(name: gravatar)
    ]
)
