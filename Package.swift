// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ThreadSafeDataStructures",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6),
    .visionOS(.v1),
  ],
  products: [
    .library(
      name: "ThreadSafeDataStructures",
      targets: ["ThreadSafeDataStructures"]
    )
  ],
  dependencies: [
    // Swift Testing framework - explicit dependency for compatibility
    .package(url: "https://github.com/apple/swift-testing.git", from: "0.10.0")
  ],
  targets: [
    .target(
      name: "ThreadSafeDataStructures"
    ),
    .testTarget(
      name: "ThreadSafeDataStructuresTests",
      dependencies: [
        "ThreadSafeDataStructures",
        .product(name: "Testing", package: "swift-testing"),
      ]
    ),
  ]
)
