import MCP
import XCTest

struct SwipeTool: MCPTool {
    static let toolName = ToolName.swipe
    static let description = "Swipe on an element or the entire app. If no element query given, swipes on the app."

    enum Args: String {
        case direction
    }

    enum Direction: String, CaseIterable {
        case up, down, left, right

        func perform(on element: XCUIElement) {
            switch self {
            case .up: element.swipeUp()
            case .down: element.swipeDown()
            case .left: element.swipeLeft()
            case .right: element.swipeRight()
            }
        }
    }

    enum SwipeError: Error {
        case elementNotFound
    }

    static let inputSchema: Value = .object([
        "type": .string("object"),
        "properties": .object([
            Args.direction.rawValue: .object([
                "type": .string("string"),
                "description": .string("Swipe direction"),
                "enum": .array(Direction.allCases.map { .string($0.rawValue) }),
            ]),
            QueryArg.elementType.rawValue: .object([
                "type": .string("string"),
                "description": .string("Element type (optional, swipes on app if omitted)"),
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
        ]),
        "required": .array([.string(Args.direction.rawValue)]),
    ])

    let app: XCUIApplication

    @MainActor
    func perform(direction: Direction, params: ElementQueryBuilder.QueryParams? = nil) throws {
        let hasQuery = params.map {
            $0.elementType != nil || $0.identifier != nil
                || $0.label != nil || $0.predicate != nil
        } ?? false

        if hasQuery, let params {
            guard let element = ElementQueryBuilder.findElement(in: app, params: params) else {
                throw SwipeError.elementNotFound
            }
            direction.perform(on: element)
        } else {
            direction.perform(on: app)
        }
    }

    @MainActor
    func execute(args: [String: Value]) throws -> CallTool.Result {
        guard let directionStr = args[Args.direction]?.stringValue else {
            return .init(content: [.text("Missing required parameter: direction")], isError: true)
        }

        guard let direction = Direction(rawValue: directionStr.lowercased()) else {
            return .init(
                content: [.text("Invalid direction: \(directionStr). Use up, down, left, or right.")],
                isError: true
            )
        }

        let params = ElementQueryBuilder.QueryParams(args: args)

        do {
            try perform(direction: direction, params: params)
            return .init(content: [.text("Swiped \(direction.rawValue)")], isError: false)
        } catch SwipeError.elementNotFound {
            return .init(content: [.text("Element not found")], isError: true)
        }
    }
}
