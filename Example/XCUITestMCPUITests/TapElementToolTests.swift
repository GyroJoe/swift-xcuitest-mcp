import XCTest
@testable import XCUITestMCP

@MainActor
final class TapElementToolTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testTapIncrementButton() {
        let tool = TapElementTool(app: app)
        let result = tool.perform(params: .init(identifier: "incrementButton"))
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.typeName, "button")

        let counterLabel = app.staticTexts["counterLabel"]
        XCTAssertEqual(counterLabel.label, "1")
    }

    func testTapMissingElementReturnsNil() {
        let tool = TapElementTool(app: app)
        let result = tool.perform(params: .init(identifier: "doesNotExist"))
        XCTAssertNil(result)
    }

    func testTapToggle() {
        let tool = TapElementTool(app: app)
        let result = tool.perform(params: .init(identifier: "featureToggle"))
        XCTAssertNotNil(result)

        let status = app.staticTexts["statusLabel"]
        XCTAssertEqual(status.label, "Feature ON")
    }
}
