// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWSignInWith3rd_GitHub",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "WWSignInWith3rd_GitHub", targets: ["WWSignInWith3rd_GitHub"]),
    ],
    dependencies: [
        .package(url: "https://github.com/William-Weng/WWSignInWith3rd_Apple", .upToNextMinor(from: "1.1.0")),
        .package(url: "https://github.com/William-Weng/WWNetworking", .upToNextMinor(from: "1.3.1")),
    ],
    targets: [
        .target(name: "WWSignInWith3rd_GitHub", dependencies: ["WWSignInWith3rd_Apple", "WWNetworking"], resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
