import XCTest
@testable import XCUITestMCP

@MainActor
final class WaitForElementToolTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testWaitForExistingElement() throws {
        let tool = WaitForElementTool(app: app)
        let result = try tool.perform(params: .init(identifier: "statusLabel"), timeout: 5.0)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.exists)
        XCTAssertEqual(result?.label, "Ready")
    }

    func testWaitForMissingElementReturnsNil() throws {
        let tool = WaitForElementTool(app: app)
        let result = try tool.perform(params: .init(identifier: "neverAppears"), timeout: 1.0)
        XCTAssertNil(result)
    }
}
