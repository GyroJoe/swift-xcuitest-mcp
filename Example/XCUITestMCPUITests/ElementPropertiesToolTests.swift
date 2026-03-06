import XCTest
@testable import XCUITestMCP

@MainActor
final class ElementPropertiesToolTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testGetProperties() {
        let tool = ElementPropertiesTool(app: app)
        let info = tool.perform(params: .init(identifier: "statusLabel"))
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.identifier, "statusLabel")
        XCTAssertEqual(info?.label, "Ready")
        XCTAssertEqual(info?.elementType, "staticText")
        XCTAssertTrue(info?.exists ?? false)
        XCTAssertNotNil(info?.frame)
        XCTAssertNotNil(info?.isEnabled)
    }

    func testMissingElementReturnsNil() {
        let tool = ElementPropertiesTool(app: app)
        let info = tool.perform(params: .init(identifier: "missing"))
        XCTAssertNil(info)
    }
}
