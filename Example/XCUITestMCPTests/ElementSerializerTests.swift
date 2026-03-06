import XCTest
@testable import XCUITestMCP

final class ElementSerializerTests: XCTestCase {
    func testEncodeElementInfo() throws {
        let info = ElementInfo(
            elementType: "button",
            identifier: "myButton",
            label: "Tap Me",
            exists: true,
            isEnabled: true,
            isSelected: false,
            frame: ElementFrame(CGRect(x: 10, y: 20, width: 100, height: 44))
        )

        let json = try ElementSerializer.encode(info)
        XCTAssertFalse(json.isEmpty)

        let data = json.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(parsed["elementType"] as? String, "button")
        XCTAssertEqual(parsed["identifier"] as? String, "myButton")
        XCTAssertEqual(parsed["label"] as? String, "Tap Me")
        XCTAssertEqual(parsed["exists"] as? Bool, true)
        XCTAssertEqual(parsed["isEnabled"] as? Bool, true)
    }

    func testEncodeElementInfoArray() throws {
        let infos = [
            ElementInfo(elementType: "button", identifier: "a", label: "A", exists: true),
            ElementInfo(elementType: "staticText", identifier: "b", label: "B", exists: true),
        ]

        let json = try ElementSerializer.encode(infos)
        let data = json.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
        XCTAssertEqual(parsed.count, 2)
        XCTAssertEqual(parsed[0]["identifier"] as? String, "a")
        XCTAssertEqual(parsed[1]["identifier"] as? String, "b")
    }

    func testFrameEncoding() throws {
        let frame = ElementFrame(CGRect(x: 1.7, y: 2.3, width: 100.9, height: 44.1))
        XCTAssertEqual(frame.x, 1)
        XCTAssertEqual(frame.y, 2)
        XCTAssertEqual(frame.width, 100)
        XCTAssertEqual(frame.height, 44)
    }

    func testEncodeWithChildren() throws {
        var parent = ElementInfo(
            elementType: "other",
            identifier: "parent",
            label: "",
            exists: true
        )
        parent.children = [
            ElementInfo(elementType: "button", identifier: "child1", label: "Child", exists: true),
        ]

        let json = try ElementSerializer.encode(parent)
        let data = json.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let children = parsed["children"] as! [[String: Any]]
        XCTAssertEqual(children.count, 1)
        XCTAssertEqual(children[0]["identifier"] as? String, "child1")
    }

    func testEncodeOmitsNilFields() throws {
        let info = ElementInfo(
            elementType: "button",
            identifier: "",
            label: "Test",
            exists: true
        )

        let json = try ElementSerializer.encode(info)
        XCTAssertFalse(json.contains("children"))
        XCTAssertFalse(json.contains("value"))
        XCTAssertFalse(json.contains("placeholderValue"))
        XCTAssertFalse(json.contains("isHittable"))
        XCTAssertFalse(json.contains("isReachable"))
    }
}
