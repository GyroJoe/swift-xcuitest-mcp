import SwiftUI
import WebKit

struct WebViewScreen: View {
    var body: some View {
        WebView()
            .accessibilityIdentifier("webView")
            .navigationTitle("Web View")
    }
}

private struct WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

private let html = """
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: -apple-system; padding: 20px; }
        input, button { font-size: 16px; padding: 8px; margin: 8px 0; }
        input { width: 100%; box-sizing: border-box; }
        h1 { font-size: 24px; }
        p { font-size: 16px; }
        #output { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Web View Test Page</h1>
    <p id="description">This page tests how XCUITest interacts with web content.</p>

    <input id="nameField" type="text" placeholder="Enter your name">
    <input id="emailField" type="email" placeholder="Enter your email">

    <button id="submitButton" onclick="document.getElementById('output').textContent = 'Hello, ' + document.getElementById('nameField').value + '!'">
        Submit
    </button>

    <button id="resetButton" onclick="document.getElementById('nameField').value = ''; document.getElementById('emailField').value = ''; document.getElementById('output').textContent = ''">
        Reset
    </button>

    <p id="output"></p>

    <a id="exampleLink" href="https://example.com">Example Link</a>
</body>
</html>
"""
