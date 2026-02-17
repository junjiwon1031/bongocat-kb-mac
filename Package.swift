// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BongoCatNoMouse",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "BongoCatNoMouse",
            path: "BongoCatNoMouse",
            exclude: ["Info.plist", "BongoCatNoMouse.entitlements", "Assets.xcassets"],
            resources: [
                .copy("Resources"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
