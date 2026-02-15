// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WMOffice",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "WMOffice", targets: ["WMOffice"])
    ],
    targets: [
        .executableTarget(
            name: "WMOffice",
            path: "Sources/WMOffice"
        )
    ]
)
