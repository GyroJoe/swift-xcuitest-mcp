import Foundation
import MCP
import XCTest

final class MCPServerSetup: @unchecked Sendable {
    let app: XCUIApplication
    let issueInterceptor: IssueInterceptor?

    init(app: XCUIApplication, issueInterceptor: IssueInterceptor? = nil) {
        self.app = app
        self.issueInterceptor = issueInterceptor
    }

    func createServer() async -> Server {
        let server = Server(
            name: "xctest-mcp-server",
            version: "1.0.0",
            capabilities: .init(tools: .init(listChanged: false))
        )

        await server.withMethodHandler(ListTools.self) { _ in
            .init(tools: ToolRegistry.allTools)
        }

        let app = self.app
        let interceptor = self.issueInterceptor
        await server.withMethodHandler(CallTool.self) { params in
            await MainActor.run {
                let args = params.arguments ?? [:]
                guard let name = ToolName(rawValue: params.name),
                      let toolType = ToolRegistry.tools[name] else {
                    return CallTool.Result(
                        content: [.text("Unknown tool: \(params.name)")],
                        isError: true
                    )
                }
                let tool = toolType.init(app: app)
                return Self.executeWithInterception(interceptor: interceptor) {
                    try tool.execute(args: args)
                }
            }
        }

        return server
    }

    private static func executeWithInterception(
        interceptor: IssueInterceptor?,
        block: () throws -> CallTool.Result
    ) -> CallTool.Result {
        interceptor?.start()

        let result: CallTool.Result
        do {
            result = try block()
        } catch {
            let issues = interceptor?.stop() ?? []
            let messages = issues.map { $0.compactDescription }
            let errorText = messages.isEmpty
                ? "Error: \(error.localizedDescription)"
                : "Error: \(error.localizedDescription); \(messages.joined(separator: "; "))"
            return CallTool.Result(content: [.text(errorText)], isError: true)
        }

        let issues = interceptor?.stop() ?? []
        if !issues.isEmpty {
            let messages = issues.map { $0.compactDescription }
            return CallTool.Result(
                content: [.text("XCTest failure: \(messages.joined(separator: "; "))")],
                isError: true
            )
        }

        return result
    }
}
