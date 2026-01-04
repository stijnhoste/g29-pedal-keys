// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "G29PedalKeys",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "g29-pedal-keys",
            path: "Sources/G29PedalKeys"
        )
    ]
)
