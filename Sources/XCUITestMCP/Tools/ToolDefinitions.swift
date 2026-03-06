import MCP
import XCTest

extension Dictionary where Key == String {
    subscript<T: RawRepresentable>(_ key: T) -> Value? where T.RawValue == String {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue }
    }
}

enum ToolName: String {
    case screenshot
    case getElementTree
    case findElements
    case tapElement
    case typeText
    case getElementProperties
    case swipe
    case waitForElement
}

protocol MCPTool {
    static var toolName: ToolName { get }
    static var description: String { get }
    static var inputSchema: Value { get }

    var app: XCUIApplication { get }
    init(app: XCUIApplication)

    @MainActor
    func execute(args: [String: Value]) throws -> CallTool.Result
}

extension MCPTool {
    static var tool: Tool {
        Tool(name: toolName.rawValue, description: description, inputSchema: inputSchema)
    }
}

enum ToolRegistry {
    static let allToolTypes: [any MCPTool.Type] = [
        ScreenshotTool.self,
        ElementTreeTool.self,
        FindElementsTool.self,
        TapElementTool.self,
        TypeTextTool.self,
        ElementPropertiesTool.self,
        SwipeTool.self,
        WaitForElementTool.self,
    ]

    static let tools: [ToolName: any MCPTool.Type] = {
        Dictionary(uniqueKeysWithValues: allToolTypes.map { ($0.toolName, $0) })
    }()

    static let allTools: [Tool] = allToolTypes.map { $0.tool }
}
