import XCTest
@testable import XCUITestMCP

final class ElementTypeMappingTests: XCTestCase {
    func testKnownTypes() {
        XCTAssertEqual(XCUIElement.ElementType(name: "button"), .button)
        XCTAssertEqual(XCUIElement.ElementType(name: "textField"), .textField)
        XCTAssertEqual(XCUIElement.ElementType(name: "staticText"), .staticText)
        XCTAssertEqual(XCUIElement.ElementType(name: "switch"), .switch)
        XCTAssertEqual(XCUIElement.ElementType(name: "slider"), .slider)
        XCTAssertEqual(XCUIElement.ElementType(name: "navigationBar"), .navigationBar)
        XCTAssertEqual(XCUIElement.ElementType(name: "application"), .application)
        XCTAssertEqual(XCUIElement.ElementType(name: "group"), .group)
        XCTAssertEqual(XCUIElement.ElementType(name: "popover"), .popover)
        XCTAssertEqual(XCUIElement.ElementType(name: "keyboard"), .keyboard)
        XCTAssertEqual(XCUIElement.ElementType(name: "map"), .map)
        XCTAssertEqual(XCUIElement.ElementType(name: "grid"), .grid)
        XCTAssertEqual(XCUIElement.ElementType(name: "statusItem"), .statusItem)
    }

    func testAliases() {
        XCTAssertEqual(XCUIElement.ElementType(name: "label"), .staticText)
        XCTAssertEqual(XCUIElement.ElementType(name: "text"), .staticText)
    }

    func testToggleIsDistinctFromSwitch() {
        // .toggle (rawValue 41) is a distinct enum case from .switch (40)
        XCTAssertEqual(XCUIElement.ElementType(name: "toggle"), .toggle)
        XCTAssertEqual(XCUIElement.ElementType(name: "switch"), .switch)
        XCTAssertEqual(XCUIElement.ElementType.toggle.name, "toggle")
        XCTAssertEqual(XCUIElement.ElementType.switch.name, "switch")
    }

    func testCaseInsensitive() {
        XCTAssertEqual(XCUIElement.ElementType(name: "Button"), .button)
        XCTAssertEqual(XCUIElement.ElementType(name: "BUTTON"), .button)
        XCTAssertEqual(XCUIElement.ElementType(name: "TextField"), .textField)
    }

    func testUnknownReturnsNil() {
        XCTAssertNil(XCUIElement.ElementType(name: "nonexistent"))
        XCTAssertNil(XCUIElement.ElementType(name: ""))
    }

    func testRoundTrip() {
        let pairs: [(String, XCUIElement.ElementType)] = [
            ("button", .button), ("cell", .cell), ("textField", .textField),
            ("staticText", .staticText), ("switch", .switch), ("slider", .slider),
            ("navigationBar", .navigationBar), ("alert", .alert), ("image", .image),
            ("application", .application), ("group", .group), ("window", .window),
            ("popover", .popover), ("keyboard", .keyboard), ("key", .key),
            ("map", .map), ("grid", .grid), ("colorWell", .colorWell),
        ]
        for (name, type) in pairs {
            XCTAssertEqual(XCUIElement.ElementType(name: name), type, "String→Type failed for \(name)")
            XCTAssertEqual(type.name, name, "Type→String failed for \(type)")
        }
    }

    func testUnknownTypeRawValue() {
        let name = XCUIElement.ElementType(rawValue: 9999)!.name
        XCTAssertTrue(name.hasPrefix("unknown("))
    }
}
