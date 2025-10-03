// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyTerm",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MyTermApp", targets: ["MyTermApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MyTermApp",
            path: "Sources/MyTermApp",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
