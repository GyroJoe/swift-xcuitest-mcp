# swift-xcuitest-mcp

An MCP server that runs inside XCUITest, giving AI agents semantic control of any iOS app.

## How it works

The server runs as a "test" inside a UI testing bundle. When you run the test, it launches your app and starts an HTTP server that exposes [MCP](https://modelcontextprotocol.io) tools. An AI agent (like Claude Code) connects to the server and can tap buttons, read the element tree, type text, take screenshots, and more — all through the accessibility hierarchy.

## Requirements

- Xcode 26.2+
- iOS 17+
- iOS Simulator (the server listens on `localhost`, which isn't accessible from a physical device)

## Installation

Add the package to your project via Swift Package Manager:

```
https://github.com/gyrojoe/swift-xcuitest-mcp
```

Then add the `XCUITestMCP` product as a dependency of your UI testing bundle target.

## Quick Start

1. Create a UI testing bundle target in your Xcode project if you don't already have one.

2. Add a runner file:

```swift
import XCUITestMCP

final class Runner: XCUITestMCPTestCase {
    @MainActor
    func testRunMCPServer() async throws {
        try await runMCPServer()
    }
}
```

3. Run the test in Xcode. The server starts listening on `localhost:8085`. The test blocks indefinitely — stop it from Xcode's test navigator when you're done. With Xcode 26.3+, the Xcode MCP server can launch the test for you.

## Available Tools

| Tool | Description |
|------|-------------|
| `screenshot` | Capture a screenshot as base64-encoded PNG |
| `getElementTree` | Get the full accessibility element hierarchy as JSON |
| `findElements` | Find elements by type, identifier, label, or predicate |
| `tapElement` | Tap a UI element |
| `typeText` | Type text into a text field |
| `getElementProperties` | Get detailed properties of a specific element |
| `swipe` | Swipe on an element or the app |
| `waitForElement` | Wait for an element to appear with a timeout |

## Configuration

Override the `port` property to use a different port:

```swift
final class Runner: XCUITestMCPTestCase {
    override var port: Int { 9000 }

    @MainActor
    func testRunMCPServer() async throws {
        try await runMCPServer()
    }
}
```

For more control, use the API directly:

```swift
import XCTest
import XCUITestMCP

final class Runner: XCTestCase {
    @MainActor
    func testRunMCPServer() async throws {
        let app = XCUIApplication()
        app.launch()
        try await XCUITestMCP.start(app: app, port: 8085)
    }
}
```

## Connecting from Claude Code

With the test running, add the MCP server:

```bash
claude mcp add --transport http xcuitest http://localhost:8085
```

## Development

The `Example/` directory contains a sample iOS app and test suite. To set it up:

```bash
cd Example
brew install xcodegen  # if not already installed
xcodegen generate
open XCUITestMCPExample.xcodeproj
```

Run all tests from the `XCUITestMCPExample` scheme.
