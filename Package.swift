// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWSignInWith3rd+GitHub",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "WWSignInWith3rd+GitHub", targets: ["WWSignInWith3rd+GitHub"]),
    ],
    dependencies: [
        .package(name: "WWSignInWith3rd+Apple", url: "https://github.com/William-Weng/WWSignInWith3rd_Apple", .upToNextMinor(from: "1.0.1")),
        .package(url: "https://github.com/William-Weng/WWNetworking", .upToNextMinor(from: "1.1.4")),
    ],
    targets: [
        .target(name: "WWSignInWith3rd+GitHub", dependencies: ["WWSignInWith3rd+Apple", "WWNetworking"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
