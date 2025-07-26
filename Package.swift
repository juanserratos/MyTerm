// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyTerm",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "MyTermApp", targets: ["MyTerm"])
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftTerm", from: "1.2.5"),
        .package(url: "https://github.com/gonzalezreal/MarkdownUI", from: "1.1.0"),
        .package(url: "https://github.com/kostub/iosMath", from: "0.9.5")
    ],
    targets: [
        .executableTarget(
            name: "MyTerm",
            dependencies: [
                "SwiftTerm",
                "MarkdownUI",
                "iosMath"
            ],
            path: "MyTerm/MyTerm",
            resources: [.process("Assets.xcassets")]
        ),
        .testTarget(
            name: "MyTermTests",
            dependencies: ["MyTerm"],
            path: "MyTerm/MyTermTests",
            sources: ["MyTermTests.swift"]
        )
    ]
)
