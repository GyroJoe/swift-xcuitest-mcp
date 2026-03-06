import Foundation
import XCTest

// XCUIApplication is thread-safe for our purposes (process-based communication)
// but isn't marked Sendable. We need this for @Sendable closures in MCP handlers.
extension XCUIApplication: @unchecked @retroactive Sendable {}

/// An MCP server that runs inside XCUITest bundles,
/// providing semantic element-level control over iOS apps.
public enum XCUITestMCP {
    /// Start the MCP server. This method blocks indefinitely.
    ///
    /// Call this from a UI test method:
    /// ```swift
    /// func testMCPServer() async throws {
    ///     let app = XCUIApplication()
    ///     app.launch()
    ///     try await XCUITestMCP.start(app: app)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - app: The XCUIApplication instance to control
    ///   - port: The HTTP port to listen on (default: 8085)
    ///   - issueInterceptor: Optional interceptor to capture XCTest failures during tool execution
    public static func start(
        app: XCUIApplication,
        port: Int = 8085,
        issueInterceptor: IssueInterceptor? = nil
    ) async throws {
        let serverSetup = MCPServerSetup(app: app, issueInterceptor: issueInterceptor)
        let listener = HTTPListener(port: port, serverSetup: serverSetup)

        print("MCP Server running on http://localhost:\(port)/mcp")

        try await listener.start()
    }
}
