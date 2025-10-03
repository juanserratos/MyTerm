// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyTermNotes",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MyTermNotes",
            targets: ["MyTermNotesApp"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MyTermNotesApp",
            resources: [
                .process("../Resources/Renderer")
            ],
            swiftSettings: [
                .define("SWIFTUI_APP")
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("WebKit")
            ]
        )
    ]
)
