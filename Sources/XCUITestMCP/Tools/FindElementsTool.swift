import MCP
import XCTest

struct FindElementsTool: MCPTool {
    static let toolName = ToolName.findElements
    static let description = "Find UI elements matching query criteria. Returns an array of matching elements with their properties."

    enum Args: String {
        case maxResults
    }

    static let inputSchema: Value = .object([
        "type": .string("object"),
        "properties": .object([
            QueryArg.elementType.rawValue: .object([
                "type": .string("string"),
                "description": .string("Element type: button, textField, staticText, image, cell, switch, slider, navigationBar, alert, etc."),
            ]),
            QueryArg.identifier.rawValue: .object([
                "type": .string("string"),
                "description": .string("Accessibility identifier (exact match)"),
            ]),
            QueryArg.label.rawValue: .object([
                "type": .string("string"),
                "description": .string("Accessibility label (case-insensitive substring match)"),
            ]),
            QueryArg.predicate.rawValue: .object([
                "type": .string("string"),
                "description": .string("NSPredicate format string for advanced queries"),
            ]),
            Args.maxResults.rawValue: .object([
                "type": .string("integer"),
                "description": .string("Maximum number of results (default: 50)"),
            ]),
        ]),
    ])

    let app: XCUIApplication

    @MainActor
    func perform(params: ElementQueryBuilder.QueryParams, maxResults: Int = 50) throws -> [ElementInfo] {
        let elements = try ElementQueryBuilder.findElements(in: app, params: params, maxResults: maxResults)
        let serializer = ElementSerializer(app: app)
        let snapshotIndex = (try? app.snapshot()).map { SnapshotIndex($0) }
        return elements.map { serializer.serializeFlat($0, snapshotIndex: snapshotIndex) }
    }

    @MainActor
    func execute(args: [String: Value]) throws -> CallTool.Result {
        let params = ElementQueryBuilder.QueryParams(args: args)
        let maxResults: Int
        if case .int(let m) = args[Args.maxResults] {
            maxResults = m
        } else {
            maxResults = 50
        }

        let results = try perform(params: params, maxResults: maxResults)
        let jsonString = try ElementSerializer.encode(results)

        return .init(
            content: [.text("Found \(results.count) element(s):\n\(jsonString)")],
            isError: false
        )
    }
}
