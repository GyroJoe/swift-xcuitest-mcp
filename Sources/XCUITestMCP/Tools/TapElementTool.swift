import MCP
import XCTest

struct TapElementTool: MCPTool {
    static let toolName = ToolName.tapElement
    static let description = "Tap a UI element. Identify the element using at least one of: identifier, label, elementType, or predicate."

    struct TapResult {
        let typeName: String
        let identifier: String
        let label: String
    }

    static let inputSchema: Value = .object([
        "type": .string("object"),
        "properties": .object([
            QueryArg.elementType.rawValue: .object([
                "type": .string("string"),
                "description": .string("Element type: button, textField, staticText, etc."),
            ]),
            QueryArg.identifier.rawValue: .object([
                "type": .string("string"),
                "description": .string("Accessibility identifier (exact match)"),
            ]),
            QueryArg.label.rawValue: .object([
                "type": .string("string"),
                "description": .string("Accessibility label (substring match)"),
            ]),
            QueryArg.index.rawValue: .object([
                "type": .string("integer"),
                "description": .string("Index among matches (0-based, default: 0)"),
            ]),
            QueryArg.predicate.rawValue: .object([
                "type": .string("string"),
                "description": .string("NSPredicate format string"),
            ]),
        ]),
    ])

    let app: XCUIApplication

    @MainActor
    func perform(params: ElementQueryBuilder.QueryParams) -> TapResult? {
        guard let element = ElementQueryBuilder.findElement(in: app, params: params) else {
            return nil
        }

        // Capture info before tapping - the element may disappear after (e.g. navigation)
        let typeName = element.elementType.name
        let id = element.identifier
        let lbl = element.label

        // SwiftUI Form wraps Toggle in a parent switch element (full row width).
        // Tapping center of that parent hits the label, not the actual control.
        // If the element is a switch with a child switch, tap the child instead.
        let targetElement: XCUIElement
        if element.elementType == .switch {
            let childSwitch = element.switches.firstMatch
            if childSwitch.exists {
                targetElement = childSwitch
            } else {
                targetElement = element
            }
        } else {
            targetElement = element
        }

        targetElement.tap()

        return TapResult(typeName: typeName, identifier: id, label: lbl)
    }

    @MainActor
    func execute(args: [String: Value]) throws -> CallTool.Result {
        let params = ElementQueryBuilder.QueryParams(args: args)

        guard let result = perform(params: params) else {
            return .init(content: [.text("Element not found")], isError: true)
        }

        return .init(
            content: [.text("Tapped \(result.typeName) identifier='\(result.identifier)' label='\(result.label)'")],
            isError: false
        )
    }
}
