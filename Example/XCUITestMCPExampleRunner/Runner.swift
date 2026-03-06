import XCUITestMCP

final class Runner: XCUITestMCPTestCase {
    @MainActor
    func testRunMCPServer() async throws {
        try await runMCPServer()
    }
}
