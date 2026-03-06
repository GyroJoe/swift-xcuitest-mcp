import XCTest

struct ElementFrame: Codable {
    let x: Int
    let y: Int
    let width: Int
    let height: Int

    init(_ frame: CGRect) {
        self.x = Int(frame.origin.x)
        self.y = Int(frame.origin.y)
        self.width = Int(frame.size.width)
        self.height = Int(frame.size.height)
    }
}

struct ElementInfo: Codable {
    let elementType: String
    let identifier: String
    let label: String
    let exists: Bool
    var isEnabled: Bool?
    var isSelected: Bool?
    var isHittable: Bool?
    var isReachable: Bool?
    var frame: ElementFrame?
    var value: String?
    var placeholderValue: String?
    var children: [ElementInfo]?
    var childCount: Int?
    var childrenTruncated: Bool?
}

/// Index of elements present in a snapshot, for fast membership checks.
struct SnapshotIndex {
    private struct Key: Hashable {
        let elementType: XCUIElement.ElementType
        let frame: CGRect
        let identifier: String
        let label: String
    }

    private let keys: Set<Key>

    init(_ snapshot: XCUIElementSnapshot) {
        var keys = Set<Key>()
        SnapshotIndex.collect(snapshot, into: &keys)
        self.keys = keys
    }

    func contains(element: XCUIElementSnapshot) -> Bool {
        keys.contains(Key(
            elementType: element.elementType,
            frame: element.frame,
            identifier: element.identifier,
            label: element.label
        ))
    }

    private static func collect(_ snapshot: XCUIElementSnapshot, into keys: inout Set<Key>) {
        keys.insert(Key(
            elementType: snapshot.elementType,
            frame: snapshot.frame,
            identifier: snapshot.identifier,
            label: snapshot.label
        ))
        for child in snapshot.children {
            collect(child, into: &keys)
        }
    }
}

struct ElementSerializer {
    let app: XCUIApplication

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    static func encode(_ info: ElementInfo) throws -> String {
        let data = try encoder.encode(info)
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    static func encode(_ infos: [ElementInfo]) throws -> String {
        let data = try encoder.encode(infos)
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    /// Serialize a full element tree using a snapshot.
    /// When a webView is encountered, its content elements are queried live
    /// since the snapshot doesn't include web content.
    @MainActor
    func serialize(_ element: XCUIElement, maxDepth: Int = 10) -> ElementInfo {
        guard element.exists else {
            return ElementInfo(
                elementType: element.elementType.name,
                identifier: element.identifier,
                label: element.label,
                exists: false
            )
        }

        guard let snapshot = try? element.snapshot() else {
            return ElementInfo(
                elementType: element.elementType.name,
                identifier: element.identifier,
                label: element.label,
                exists: false
            )
        }

        var tree = serializeSnapshot(snapshot, maxDepth: maxDepth, currentDepth: 0)
        injectHiddenWebViewContent(&tree)
        return tree
    }

    /// If a window contains only "other" elements (e.g. SFSafariViewController),
    /// check if it's actually hosting a webView and inject its content.
    @MainActor
    private func injectHiddenWebViewContent(_ root: inout ElementInfo) {
        guard var windows = root.children else { return }

        guard let index = windows.firstIndex(where: {
            $0.elementType == "window" && containsOnlyOther($0)
        }) else { return }

        let webView = app.webViews.firstMatch
        guard webView.exists else { return }

        let query = webView.descendants(matching: .any)
        let count = min(query.count, 100)
        var content: [ElementInfo] = []
        for i in 0..<count {
            let el = query.element(boundBy: i)
            if el.exists {
                content.append(serializeFlat(el))
            }
        }

        if !content.isEmpty {
            windows[index].children = content
            root.children = windows
        }
    }

    private func containsOnlyOther(_ info: ElementInfo) -> Bool {
        for child in info.children ?? [] {
            if child.elementType != "other" { return false }
            if !containsOnlyOther(child) { return false }
        }
        return true
    }

    @MainActor
    private func serializeSnapshot(
        _ snapshot: XCUIElementSnapshot,
        maxDepth: Int,
        currentDepth: Int
    ) -> ElementInfo {
        var info = ElementInfo(
            elementType: snapshot.elementType.name,
            identifier: snapshot.identifier,
            label: snapshot.label,
            exists: true,
            isEnabled: snapshot.isEnabled,
            isSelected: snapshot.isSelected,
            frame: ElementFrame(snapshot.frame)
        )

        if let value = snapshot.value {
            info.value = "\(value)"
        }

        if let placeholderValue = snapshot.placeholderValue {
            info.placeholderValue = placeholderValue
        }

        if snapshot.elementType == .webView {
            let webViews = app.webViews
            for i in 0..<webViews.count {
                let wv = webViews.element(boundBy: i)
                if wv.exists && wv.frame == snapshot.frame {
                    let query = wv.descendants(matching: .any)
                    let count = min(query.count, 100)
                    var children: [ElementInfo] = []
                    for j in 0..<count {
                        let el = query.element(boundBy: j)
                        if el.exists {
                            children.append(serializeFlat(el))
                        }
                    }
                    info.children = children
                    break
                }
            }
        } else if currentDepth < maxDepth {
            let children = snapshot.children
            if children.count > 0 && children.count <= 100 {
                info.children = children.map {
                    serializeSnapshot($0, maxDepth: maxDepth, currentDepth: currentDepth + 1)
                }
            } else if children.count > 100 {
                info.childCount = children.count
                info.childrenTruncated = true
            }
        }

        return info
    }

    /// Serialize a single element (no children).
    /// If `snapshotIndex` is provided, sets `isReachable` based on whether the element
    /// appears in the snapshot, and includes `isHittable`.
    func serializeFlat(_ element: XCUIElement, snapshotIndex: SnapshotIndex? = nil) -> ElementInfo {
        guard element.exists else {
            return ElementInfo(
                elementType: element.elementType.name,
                identifier: element.identifier,
                label: element.label,
                exists: false
            )
        }

        guard let snapshot = try? element.snapshot() else {
            return ElementInfo(
                elementType: element.elementType.name,
                identifier: element.identifier,
                label: element.label,
                exists: false
            )
        }

        var info = ElementInfo(
            elementType: snapshot.elementType.name,
            identifier: snapshot.identifier,
            label: snapshot.label,
            exists: true,
            isEnabled: snapshot.isEnabled,
            isSelected: snapshot.isSelected,
            frame: ElementFrame(snapshot.frame)
        )

        if let value = snapshot.value {
            info.value = "\(value)"
        }

        if let placeholderValue = snapshot.placeholderValue {
            info.placeholderValue = placeholderValue
        }

        if snapshotIndex != nil {
            info.isHittable = element.isHittable
            info.isReachable = snapshotIndex?.contains(element: snapshot) ?? false
        }

        return info
    }
}
