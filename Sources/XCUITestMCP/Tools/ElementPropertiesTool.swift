import MCP
import XCTest

struct ElementPropertiesTool: MCPTool {
    static let toolName = ToolName.getElementProperties
    static let description = "Get detailed properties (label, value, enabled, selected, frame, etc.) of a specific element."

    static let inputSchema: Value = .object([
        "type": .string("object"),
        "properties": .object([
            QueryArg.elementType.rawValue: .object([
                "type": .string("string"),
                "description": .string("Element type"),
            ]),
            QueryArg.identifier.rawValue: .object([
                "type": .string("string"),
                "description": .string("Accessibility identifier"),
            ]),
            QueryArg.label.rawValue: .object([
                "type": .string("string"),
                "description": .string("Accessibility label"),
            ]),
            QueryArg.index.rawValue: .object([
                "type": .string("integer"),
                "description": .string("Index of element (0-based)"),
            ]),
            QueryArg.predicate.rawValue: .object([
                "type": .string("string"),
                "description": .string("NSPredicate format string"),
            ]),
        ]),
    ])

    let app: XCUIApplication

    @MainActor
    func perform(params: ElementQueryBuilder.QueryParams) -> ElementInfo? {
        guard let element = ElementQueryBuilder.findElement(in: app, params: params) else {
            return nil
        }
        return ElementSerializer(app: app).serializeFlat(element)
    }

    @MainActor
    func execute(args: [String: Value]) throws -> CallTool.Result {
        let params = ElementQueryBuilder.QueryParams(args: args)

        guard let properties = perform(params: params) else {
            return .init(content: [.text("Element not found")], isError: true)
        }

        let jsonString = try ElementSerializer.encode(properties)
        return .init(content: [.text(jsonString)], isError: false)
    }
}
