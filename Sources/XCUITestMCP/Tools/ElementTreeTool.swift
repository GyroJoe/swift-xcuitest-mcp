import MCP
import XCTest

struct ElementTreeTool: MCPTool {
    static let toolName = ToolName.getElementTree
    static let description = "Get the full accessibility element hierarchy as JSON. Use this first to understand the current UI state."

    enum Args: String {
        case maxDepth
    }

    static let inputSchema: Value = .object([
        "type": .string("object"),
        "properties": .object([
            Args.maxDepth.rawValue: .object([
                "type": .string("integer"),
                "description": .string("Maximum depth to traverse (default: 10)"),
            ]),
        ]),
    ])

    let app: XCUIApplication

    @MainActor
    func perform(maxDepth: Int = 10) -> ElementInfo {
        ElementSerializer(app: app).serialize(app, maxDepth: maxDepth)
    }

    @MainActor
    func execute(args: [String: Value]) throws -> CallTool.Result {
        let maxDepth: Int
        if case .int(let d) = args[Args.maxDepth] {
            maxDepth = d
        } else {
            maxDepth = 10
        }

        let tree = perform(maxDepth: maxDepth)
        let jsonString = try ElementSerializer.encode(tree)

        return .init(
            content: [.text(jsonString)],
            isError: false
        )
    }
}
