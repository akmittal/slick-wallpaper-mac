// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SlickWallpaper",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.3")
    ],
    targets: [
        .executableTarget(
            name: "SlickWallpaper",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Sources/SlickWallpaper",
            resources: [
                .copy("Resources/quoteitup.db")
            ]
        )
    ]
)
