import XCTest
@testable import XCUITestMCP

@MainActor
final class ElementQueryBuilderTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testFindByIdentifier() {
        let params = ElementQueryBuilder.QueryParams(identifier: "statusLabel")
        let element = ElementQueryBuilder.findElement(in: app, params: params)
        XCTAssertNotNil(element)
        XCTAssertEqual(element?.label, "Ready")
    }

    func testFindByType() throws {
        let params = ElementQueryBuilder.QueryParams(elementType: "button")
        let elements = try ElementQueryBuilder.findElements(in: app, params: params)
        XCTAssertGreaterThanOrEqual(elements.count, 4)
    }

    func testFindByLabel() {
        let params = ElementQueryBuilder.QueryParams(label: "Increment")
        let element = ElementQueryBuilder.findElement(in: app, params: params)
        XCTAssertNotNil(element)
        XCTAssertEqual(element?.elementType, .button)
    }

    func testFindByPredicate() {
        let params = ElementQueryBuilder.QueryParams(predicate: "identifier == 'mainTextField'")
        let element = ElementQueryBuilder.findElement(in: app, params: params)
        XCTAssertNotNil(element)
        XCTAssertEqual(element?.identifier, "mainTextField")
    }

    func testFindWithIndex() {
        let params0 = ElementQueryBuilder.QueryParams(elementType: "button", index: 0)
        let params1 = ElementQueryBuilder.QueryParams(elementType: "button", index: 1)
        let first = ElementQueryBuilder.findElement(in: app, params: params0)
        let second = ElementQueryBuilder.findElement(in: app, params: params1)
        XCTAssertNotNil(first)
        XCTAssertNotNil(second)
        XCTAssertNotEqual(first?.identifier, second?.identifier)
    }

    func testFindMissingReturnsNil() {
        let params = ElementQueryBuilder.QueryParams(identifier: "doesNotExist")
        let element = ElementQueryBuilder.findElement(in: app, params: params)
        XCTAssertNil(element)
    }

    func testFindElementsRespectsMaxResults() throws {
        let params = ElementQueryBuilder.QueryParams(elementType: "any")
        let elements = try ElementQueryBuilder.findElements(in: app, params: params, maxResults: 3)
        XCTAssertLessThanOrEqual(elements.count, 3)
    }
}
