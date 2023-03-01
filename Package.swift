// swift-tools-version: 5.7

import PackageDescription

let package = Package(name: "TrackerLib",
                      platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v9)],
                      products: [
                          .library(name: "TrackerLib",
                                   targets: ["TrackerLib"]),
                      ],
                      dependencies: [
                          .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.4"),
                          .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.9"),
                      ],
                      targets: [
                          .target(name: "TrackerLib",
                                  dependencies: [
                                      .product(name: "Collections", package: "swift-collections"),
                                      .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                                  ],
                                  path: "Sources",
                                  resources: [
                                      .process("Resources"),
                                  ]),
                          .testTarget(name: "TrackerLibTests",
                                      dependencies: ["TrackerLib"],
                                      path: "Tests"),
                      ])
