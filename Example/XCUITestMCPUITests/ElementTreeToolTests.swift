import XCTest
@testable import XCUITestMCP

@MainActor
final class ElementTreeToolTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testPerformReturnsTree() {
        let tool = ElementTreeTool(app: app)
        let tree = tool.perform()
        XCTAssertEqual(tree.elementType, "application")
        XCTAssertTrue(tree.exists)

        let nodeCount = countNodes(tree)
        XCTAssertGreaterThan(nodeCount, 1, "Tree should have more than just the root")
    }

    func testMaxDepthLimitsTree() {
        let tool = ElementTreeTool(app: app)

        func maxDepth(_ info: ElementInfo) -> Int {
            guard let children = info.children, !children.isEmpty else { return 0 }
            return 1 + children.map { maxDepth($0) }.max()!
        }

        let shallow = tool.perform(maxDepth: 1)
        let deep = tool.perform(maxDepth: 5)
        XCTAssertLessThanOrEqual(maxDepth(shallow), 1)
        XCTAssertGreaterThan(maxDepth(deep), 1)
    }

    func testWebViewContentAppearsInTree() {
        app.buttons["webViewLink"].tap()
        let webView = app.webViews["webView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let tool = ElementTreeTool(app: app)
        let tree = tool.perform(maxDepth: 15)

        let webViewNode = findNode(tree) { $0.elementType == "webView" && $0.identifier == "webView" }
        XCTAssertNotNil(webViewNode, "Should find the webView node")

        let children = webViewNode?.children ?? []
        let types = Set(children.map(\.elementType))
        XCTAssertTrue(types.contains("textField"), "Should contain text fields")
        XCTAssertTrue(types.contains("button"), "Should contain buttons")
        XCTAssertTrue(types.contains("link"), "Should contain links")
    }

    private func countNodes(_ info: ElementInfo) -> Int {
        1 + (info.children ?? []).reduce(0) { $0 + countNodes($1) }
    }

    private func findNode(_ info: ElementInfo, where predicate: (ElementInfo) -> Bool) -> ElementInfo? {
        if predicate(info) { return info }
        for child in info.children ?? [] {
            if let found = findNode(child, where: predicate) { return found }
        }
        return nil
    }
}
