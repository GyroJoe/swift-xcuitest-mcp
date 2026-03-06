import os
import XCTest

/// A base XCTestCase that launches the app and starts the MCP server.
///
/// Subclass this in your UI test target:
/// ```swift
/// import XCUITestMCP
///
/// final class Runner: XCUITestMCPTestCase {
///     func testRunMCPServer() async throws {
///         try await runMCPServer()
///     }
/// }
/// ```
///
/// Override `port` to customize the listening port.
open class XCUITestMCPTestCase: XCTestCase {
    /// The port the MCP server listens on. Override to customize.
    open var port: Int { 8085 }

    let issueInterceptor = IssueInterceptor()

    /// Intercepts XCTest issues during MCP tool execution.
    ///
    /// XCUITest actions like `tap()` and `typeText()` record XCTest issues
    /// (via this method) when they fail. Normally this triggers test
    /// interruption via a run loop observer, crashing the long-running
    /// MCP server. During tool execution, we capture issues here instead
    /// of forwarding to super, preventing XCTest from ever seeing them.
    /// The captured issues are returned as MCP error responses.
    override open func record(_ issue: XCTIssue) {
        if issueInterceptor.isIntercepting {
            issueInterceptor.capture(issue)
        } else {
            super.record(issue)
        }
    }

    /// Launches the app and starts the MCP server. Call from a test method.
    @MainActor
    open func runMCPServer() async throws {
        continueAfterFailure = true
        let app = XCUIApplication()
        app.launch()
        try await XCUITestMCP.start(app: app, port: port, issueInterceptor: issueInterceptor)
    }
}

/// Captures XCTest issues during tool execution, preventing them from being
/// recorded on the test case (which would trigger test interruption).
public final class IssueInterceptor: Sendable {
    private struct State {
        var isIntercepting = false
        var issues: [XCTIssue] = []
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    var isIntercepting: Bool {
        state.withLock { $0.isIntercepting }
    }

    func start() {
        state.withLock {
            $0.isIntercepting = true
            $0.issues.removeAll()
        }
    }

    func stop() -> [XCTIssue] {
        state.withLock {
            $0.isIntercepting = false
            let captured = $0.issues
            $0.issues.removeAll()
            return captured
        }
    }

    func capture(_ issue: XCTIssue) {
        state.withLock {
            $0.issues.append(issue)
        }
    }
}
