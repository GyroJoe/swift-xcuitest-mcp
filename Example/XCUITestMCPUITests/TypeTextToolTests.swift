import XCTest
@testable import XCUITestMCP

@MainActor
final class TypeTextToolTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testTypeIntoDefaultField() throws {
        let tool = TypeTextTool(app: app)
        let name = try tool.perform(text: "Hello")
        XCTAssertEqual(name, "mainTextField")
        XCTAssertEqual(app.textFields["mainTextField"].value as? String, "Hello")
    }

    func testTypeIntoSpecificField() throws {
        let tool = TypeTextTool(app: app)
        let name = try tool.perform(
            text: "Some notes",
            params: .init(identifier: "notesTextField")
        )
        XCTAssertEqual(name, "notesTextField")
        XCTAssertEqual(app.textFields["notesTextField"].value as? String, "Some notes")

        // Verify the main field was not affected
        XCTAssertEqual(app.textFields["mainTextField"].value as? String, "Enter text here") // placeholder
    }

    func testClearFirst() throws {
        let tool = TypeTextTool(app: app)
        _ = try tool.perform(text: "Initial")
        _ = try tool.perform(text: "Replaced", clearFirst: true)
        XCTAssertEqual(app.textFields["mainTextField"].value as? String, "Replaced")
    }

    func testClearFirstWithLongText() throws {
        let tool = TypeTextTool(app: app)
        _ = try tool.perform(
            text: "This is a long piece of text that should fill up the text field and go beyond the visible area"
        )
        _ = try tool.perform(text: "Short", clearFirst: true)
        XCTAssertEqual(app.textFields["mainTextField"].value as? String, "Short")
    }

    func testFieldNotFoundThrows() {
        let tool = TypeTextTool(app: app)
        XCTAssertThrowsError(
            try tool.perform(text: "x", params: .init(identifier: "nonexistent"))
        ) { error in
            XCTAssertTrue(error is TypeTextTool.TypeTextError)
        }
    }
}
