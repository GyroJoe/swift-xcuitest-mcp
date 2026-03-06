import XCTest
@testable import XCUITestMCP

@MainActor
final class ScreenshotToolTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testPerformReturnsValidPNG() {
        let tool = ScreenshotTool(app: app)
        let base64 = tool.perform()
        XCTAssertFalse(base64.isEmpty)

        let data = Data(base64Encoded: base64)
        XCTAssertNotNil(data)
        // PNG magic bytes: 89 50 4E 47
        XCTAssertEqual(data?.prefix(4), Data([0x89, 0x50, 0x4E, 0x47]))
    }
}
