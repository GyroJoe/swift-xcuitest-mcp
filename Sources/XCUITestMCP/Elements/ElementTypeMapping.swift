import XCTest

extension XCUIElement.ElementType {
    init?(name: String) {
        switch name.lowercased() {
        case "any": self = .any
        case "other": self = .other
        case "application": self = .application
        case "group": self = .group
        case "window": self = .window
        case "sheet": self = .sheet
        case "drawer": self = .drawer
        case "alert": self = .alert
        case "dialog": self = .dialog
        case "button": self = .button
        case "radiobutton": self = .radioButton
        case "radiogroup": self = .radioGroup
        case "checkbox": self = .checkBox
        case "disclosuretriangle": self = .disclosureTriangle
        case "popupbutton": self = .popUpButton
        case "combobox": self = .comboBox
        case "menubutton": self = .menuButton
        case "toolbarbutton": self = .toolbarButton
        case "popover": self = .popover
        case "keyboard": self = .keyboard
        case "key": self = .key
        case "navigationbar": self = .navigationBar
        case "tabbar": self = .tabBar
        case "tabgroup": self = .tabGroup
        case "toolbar": self = .toolbar
        case "statusbar": self = .statusBar
        case "table": self = .table
        case "tablerow": self = .tableRow
        case "tablecolumn": self = .tableColumn
        case "outline": self = .outline
        case "outlinerow": self = .outlineRow
        case "browser": self = .browser
        case "collectionview": self = .collectionView
        case "slider": self = .slider
        case "pageindicator": self = .pageIndicator
        case "progressindicator": self = .progressIndicator
        case "activityindicator": self = .activityIndicator
        case "segmentedcontrol": self = .segmentedControl
        case "picker": self = .picker
        case "pickerwheel": self = .pickerWheel
        case "switch": self = .switch
        case "toggle": self = .toggle
        case "link": self = .link
        case "image": self = .image
        case "icon": self = .icon
        case "searchfield": self = .searchField
        case "scrollview": self = .scrollView
        case "scrollbar": self = .scrollBar
        case "statictext": self = .staticText
        case "textfield": self = .textField
        case "securetextfield": self = .secureTextField
        case "datepicker": self = .datePicker
        case "textview": self = .textView
        case "menu": self = .menu
        case "menuitem": self = .menuItem
        case "menubar": self = .menuBar
        case "menubaritem": self = .menuBarItem
        case "map": self = .map
        case "webview": self = .webView
        case "incrementarrow": self = .incrementArrow
        case "decrementarrow": self = .decrementArrow
        case "timeline": self = .timeline
        case "ratingindicator": self = .ratingIndicator
        case "valueindicator": self = .valueIndicator
        case "splitgroup": self = .splitGroup
        case "splitter": self = .splitter
        case "relevanceindicator": self = .relevanceIndicator
        case "colorwell": self = .colorWell
        case "helptag": self = .helpTag
        case "matte": self = .matte
        case "dockitem": self = .dockItem
        case "ruler": self = .ruler
        case "rulermarker": self = .rulerMarker
        case "grid": self = .grid
        case "levelindicator": self = .levelIndicator
        case "cell": self = .cell
        case "layoutarea": self = .layoutArea
        case "layoutitem": self = .layoutItem
        case "handle": self = .handle
        case "stepper": self = .stepper
        case "tab": self = .tab
        case "touchbar": self = .touchBar
        case "statusitem": self = .statusItem
        // Aliases
        case "label", "text": self = .staticText
        default: return nil
        }
    }

    var name: String {
        switch self {
        case .any: return "any"
        case .other: return "other"
        case .application: return "application"
        case .group: return "group"
        case .window: return "window"
        case .sheet: return "sheet"
        case .drawer: return "drawer"
        case .alert: return "alert"
        case .dialog: return "dialog"
        case .button: return "button"
        case .radioButton: return "radioButton"
        case .radioGroup: return "radioGroup"
        case .checkBox: return "checkBox"
        case .disclosureTriangle: return "disclosureTriangle"
        case .popUpButton: return "popUpButton"
        case .comboBox: return "comboBox"
        case .menuButton: return "menuButton"
        case .toolbarButton: return "toolbarButton"
        case .popover: return "popover"
        case .keyboard: return "keyboard"
        case .key: return "key"
        case .navigationBar: return "navigationBar"
        case .tabBar: return "tabBar"
        case .tabGroup: return "tabGroup"
        case .toolbar: return "toolbar"
        case .statusBar: return "statusBar"
        case .table: return "table"
        case .tableRow: return "tableRow"
        case .tableColumn: return "tableColumn"
        case .outline: return "outline"
        case .outlineRow: return "outlineRow"
        case .browser: return "browser"
        case .collectionView: return "collectionView"
        case .slider: return "slider"
        case .pageIndicator: return "pageIndicator"
        case .progressIndicator: return "progressIndicator"
        case .activityIndicator: return "activityIndicator"
        case .segmentedControl: return "segmentedControl"
        case .picker: return "picker"
        case .pickerWheel: return "pickerWheel"
        case .switch: return "switch"
        case .toggle: return "toggle"
        case .link: return "link"
        case .image: return "image"
        case .icon: return "icon"
        case .searchField: return "searchField"
        case .scrollView: return "scrollView"
        case .scrollBar: return "scrollBar"
        case .staticText: return "staticText"
        case .textField: return "textField"
        case .secureTextField: return "secureTextField"
        case .datePicker: return "datePicker"
        case .textView: return "textView"
        case .menu: return "menu"
        case .menuItem: return "menuItem"
        case .menuBar: return "menuBar"
        case .menuBarItem: return "menuBarItem"
        case .map: return "map"
        case .webView: return "webView"
        case .incrementArrow: return "incrementArrow"
        case .decrementArrow: return "decrementArrow"
        case .timeline: return "timeline"
        case .ratingIndicator: return "ratingIndicator"
        case .valueIndicator: return "valueIndicator"
        case .splitGroup: return "splitGroup"
        case .splitter: return "splitter"
        case .relevanceIndicator: return "relevanceIndicator"
        case .colorWell: return "colorWell"
        case .helpTag: return "helpTag"
        case .matte: return "matte"
        case .dockItem: return "dockItem"
        case .ruler: return "ruler"
        case .rulerMarker: return "rulerMarker"
        case .grid: return "grid"
        case .levelIndicator: return "levelIndicator"
        case .cell: return "cell"
        case .layoutArea: return "layoutArea"
        case .layoutItem: return "layoutItem"
        case .handle: return "handle"
        case .stepper: return "stepper"
        case .tab: return "tab"
        case .touchBar: return "touchBar"
        case .statusItem: return "statusItem"
        @unknown default: return "unknown(\(rawValue))"
        }
    }
}
