import XCTest
@testable import XCUITestMCP

@MainActor
final class FindElementsToolTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testFindButtons() throws {
        let tool = FindElementsTool(app: app)
        let params = ElementQueryBuilder.QueryParams(elementType: "button")
        let results = try tool.perform(params: params)
        // Increment, Decrement, Submit, Reset at minimum
        XCTAssertGreaterThanOrEqual(results.count, 4)
        XCTAssertTrue(results.allSatisfy { $0.elementType == "button" })
    }

    func testFindByIdentifier() throws {
        let tool = FindElementsTool(app: app)
        let params = ElementQueryBuilder.QueryParams(identifier: "submitButton")
        let results = try tool.perform(params: params)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.identifier, "submitButton")
    }

    func testFindElementsBehindModalNotReachable() throws {
        app.buttons["showModalButton"].tap()
        let modal = app.staticTexts["modalTitle"]
        XCTAssertTrue(modal.waitForExistence(timeout: 2))

        let tool = FindElementsTool(app: app)
        let results = try tool.perform(params: .init(elementType: "button"))

        let submit = results.first { $0.identifier == "submitButton" }
        XCTAssertNotNil(submit)
        XCTAssertEqual(submit?.isReachable, false)
        XCTAssertEqual(submit?.isHittable, false)

        let modalAction = results.first { $0.identifier == "modalActionButton" }
        XCTAssertNotNil(modalAction)
        XCTAssertEqual(modalAction?.isReachable, true)
        XCTAssertEqual(modalAction?.isHittable, true)
    }
}
