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
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "WMOffice",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: "Sources/WMOffice"
        )
    ]
)
