import XCTest
@testable import XCUITestMCP

@MainActor
final class SwipeToolTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testSwipeOnElement() throws {
        let tool = SwipeTool(app: app)
        try tool.perform(direction: .left, params: .init(identifier: "swipeArea"))

        let status = app.staticTexts["statusLabel"]
        XCTAssertEqual(status.label, "Swiped left")
    }

    func testSwipeOnMissingElementThrows() {
        let tool = SwipeTool(app: app)
        XCTAssertThrowsError(
            try tool.perform(direction: .up, params: .init(identifier: "nonexistent"))
        ) { error in
            XCTAssertTrue(error is SwipeTool.SwipeError)
        }
    }
}
