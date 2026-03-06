import MCP
import XCTest

struct ScreenshotTool: MCPTool {
    static let toolName = ToolName.screenshot
    static let description = "Capture a screenshot of the current screen as a base64-encoded PNG image"
    static let inputSchema: Value = .object([
        "type": .string("object"),
        "properties": .object([:]),
    ])

    let app: XCUIApplication

    @MainActor
    func perform() -> String {
        let screenshot = app.screenshot()
        let pngData = screenshot.pngRepresentation
        return pngData.base64EncodedString()
    }

    @MainActor
    func execute(args: [String: Value]) throws -> CallTool.Result {
        let base64 = perform()
        return .init(
            content: [.image(data: base64, mimeType: "image/png", metadata: nil)],
            isError: false
        )
    }
}
