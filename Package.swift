// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "swift-xcuitest-mcp",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "XCUITestMCP", targets: ["XCUITestMCP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.11.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/sindresorhus/ExceptionCatcher.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "XCUITestMCP",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ExceptionCatcher", package: "ExceptionCatcher"),
            ]
        ),
    ]
)
