import MCP
import XCTest

struct WaitForElementTool: MCPTool {
    static let toolName = ToolName.waitForElement
    static let description = "Wait for an element to appear with a timeout. Returns the element properties once found."

    enum Args: String {
        case timeout
    }

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
            QueryArg.predicate.rawValue: .object([
                "type": .string("string"),
                "description": .string("NSPredicate format string"),
            ]),
            Args.timeout.rawValue: .object([
                "type": .string("number"),
                "description": .string("Timeout in seconds (default: 10)"),
            ]),
        ]),
    ])

    let app: XCUIApplication

    @MainActor
    func perform(
        params: ElementQueryBuilder.QueryParams,
        timeout: TimeInterval = 10.0
    ) throws -> ElementInfo? {
        let query = try ElementQueryBuilder.buildQuery(in: app, params: params)
        let element = query.firstMatch

        if element.waitForExistence(timeout: timeout) {
            return ElementSerializer(app: app).serializeFlat(element)
        }
        return nil
    }

    @MainActor
    func execute(args: [String: Value]) throws -> CallTool.Result {
        let timeout: TimeInterval
        if let t = args[Args.timeout]?.intValue {
            timeout = TimeInterval(t)
        } else if let t = args[Args.timeout]?.doubleValue {
            timeout = t
        } else {
            timeout = 10.0
        }

        let params = ElementQueryBuilder.QueryParams(args: args)

        if let info = try perform(params: params, timeout: timeout) {
            let jsonString = try ElementSerializer.encode(info)
            return .init(content: [.text("Element found:\n\(jsonString)")], isError: false)
        } else {
            return .init(content: [.text("Element not found within \(timeout)s timeout")], isError: true)
        }
    }
}
