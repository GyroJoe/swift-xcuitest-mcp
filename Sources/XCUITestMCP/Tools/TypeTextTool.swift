import MCP
import XCTest

struct TypeTextTool: MCPTool {
    static let toolName = ToolName.typeText
    static let description = "Type text into a text field. If no element query params given, types into the first textField."

    enum Args: String {
        case text
        case clearFirst
    }

    enum TypeTextError: Error {
        case fieldNotFound
    }

    static let inputSchema: Value = .object([
        "type": .string("object"),
        "properties": .object([
            Args.text.rawValue: .object([
                "type": .string("string"),
                "description": .string("The text to type"),
            ]),
            QueryArg.identifier.rawValue: .object([
                "type": .string("string"),
                "description": .string("Accessibility identifier of the text field"),
            ]),
            QueryArg.label.rawValue: .object([
                "type": .string("string"),
                "description": .string("Accessibility label of the text field"),
            ]),
            QueryArg.index.rawValue: .object([
                "type": .string("integer"),
                "description": .string("Index of text field (0-based, default: 0)"),
            ]),
            Args.clearFirst.rawValue: .object([
                "type": .string("boolean"),
                "description": .string("Clear existing text before typing (default: false)"),
            ]),
        ]),
        "required": .array([.string(Args.text.rawValue)]),
    ])

    let app: XCUIApplication

    /// Types text into a field. Returns the field name/identifier.
    @MainActor
    func perform(
        text: String,
        clearFirst: Bool = false,
        params: ElementQueryBuilder.QueryParams? = nil
    ) throws -> String {
        let effectiveParams: ElementQueryBuilder.QueryParams
        if let params,
           params.elementType != nil || params.identifier != nil
            || params.label != nil || params.predicate != nil
        {
            effectiveParams = params
        } else {
            effectiveParams = .init(elementType: "textField")
        }

        guard let element = ElementQueryBuilder.findElement(in: app, params: effectiveParams) else {
            throw TypeTextError.fieldNotFound
        }

        element.tap()

        if clearFirst {
            element.tap(withNumberOfTaps: 3, numberOfTouches: 1)
            element.typeText(XCUIKeyboardKey.delete.rawValue)
        }

        element.typeText(text)

        return element.identifier.isEmpty ? "text field" : element.identifier
    }

    @MainActor
    func execute(args: [String: Value]) throws -> CallTool.Result {
        guard let text = args[Args.text]?.stringValue else {
            return .init(content: [.text("Missing required parameter: text")], isError: true)
        }

        let clearFirst = args[Args.clearFirst]?.boolValue ?? false
        let params = ElementQueryBuilder.QueryParams(args: args)

        do {
            let name = try perform(text: text, clearFirst: clearFirst, params: params)
            return .init(content: [.text("Typed '\(text)' into \(name)")], isError: false)
        } catch TypeTextError.fieldNotFound {
            return .init(content: [.text("Text field not found")], isError: true)
        }
    }
}
