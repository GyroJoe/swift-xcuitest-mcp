import ExceptionCatcher
import MCP
import XCTest

enum QueryArg: String {
    case elementType
    case identifier
    case label
    case predicate
    case index
}

enum ElementQueryBuilder {
    struct QueryParams {
        var elementType: String?
        var identifier: String?
        var label: String?
        var predicate: String?
        var index: Int?

        init(
            elementType: String? = nil,
            identifier: String? = nil,
            label: String? = nil,
            predicate: String? = nil,
            index: Int? = nil
        ) {
            self.elementType = elementType
            self.identifier = identifier
            self.label = label
            self.predicate = predicate
            self.index = index
        }

        init(args: [String: Value]) {
            self.init(
                elementType: args[QueryArg.elementType]?.stringValue,
                identifier: args[QueryArg.identifier]?.stringValue,
                label: args[QueryArg.label]?.stringValue,
                predicate: args[QueryArg.predicate]?.stringValue,
                index: args[QueryArg.index]?.intValue
            )
        }
    }

    /// Find all matching elements as an array
    static func findElements(
        in app: XCUIApplication,
        params: QueryParams,
        maxResults: Int = 50
    ) throws -> [XCUIElement] {
        let query = try buildQuery(in: app, params: params)

        let count = min(query.count, maxResults)
        var results: [XCUIElement] = []
        for i in 0..<count {
            let el = query.element(boundBy: i)
            if el.exists { results.append(el) }
        }
        return results
    }

    /// Find a single element by query + optional index
    static func findElement(
        in app: XCUIApplication,
        params: QueryParams
    ) -> XCUIElement? {
        guard let query = try? buildQuery(in: app, params: params) else { return nil }
        let index = params.index ?? 0
        guard query.count > index else { return nil }

        let element = query.element(boundBy: index)
        return element.exists ? element : nil
    }

    static func buildQuery(
        in app: XCUIApplication,
        params: QueryParams
    ) throws -> XCUIElementQuery {
        var query: XCUIElementQuery

        if let typeName = params.elementType,
           let type = XCUIElement.ElementType(name: typeName)
        {
            query = app.descendants(matching: type)
        } else {
            query = app.descendants(matching: .any)
        }

        if let identifier = params.identifier {
            query = query.matching(identifier: identifier)
        }

        if let label = params.label {
            let pred = NSPredicate(format: "label CONTAINS[cd] %@", label)
            query = query.matching(pred)
        }

        if let predicateStr = params.predicate {
            let pred = NSPredicate(format: predicateStr)
            query = try ExceptionCatcher.catch { query.matching(pred) }
        }

        return query
    }
}
