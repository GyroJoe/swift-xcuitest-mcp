import Foundation
import Logging
import MCP
@preconcurrency import NIOCore
@preconcurrency import NIOPosix
@preconcurrency import NIOHTTP1

actor HTTPListener {
    private let port: Int
    private let serverSetup: MCPServerSetup
    private let transport: StatelessHTTPServerTransport
    private var channel: Channel?

    nonisolated let logger: Logger

    init(port: Int, serverSetup: MCPServerSetup) {
        self.port = port
        self.serverSetup = serverSetup
        self.logger = Logger(label: "xcuitest-mcp")
        self.transport = StatelessHTTPServerTransport(logger: logger)
    }

    func start() async throws {
        let server = await serverSetup.createServer()
        try await server.start(transport: transport)

        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline().flatMap {
                    channel.pipeline.addHandler(HTTPHandler(listener: self))
                }
            }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)

        let channel = try await bootstrap.bind(host: "127.0.0.1", port: port).get()
        self.channel = channel

        try await channel.closeFuture.get()
    }

    var endpoint: String { "/mcp" }

    func handleHTTPRequest(_ request: HTTPRequest) async -> HTTPResponse {
        guard request.method.uppercased() == "POST" else {
            return .error(statusCode: 405, .invalidRequest("Only POST is supported"))
        }

        return await transport.handleRequest(request)
    }
}

// MARK: - NIO HTTP Handler

private final class HTTPHandler: ChannelInboundHandler, @unchecked Sendable {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    private let listener: HTTPListener

    private struct RequestState {
        var head: HTTPRequestHead
        var bodyBuffer: ByteBuffer
    }

    private var requestState: RequestState?

    init(listener: HTTPListener) {
        self.listener = listener
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let part = unwrapInboundIn(data)

        switch part {
        case .head(let head):
            requestState = RequestState(
                head: head,
                bodyBuffer: context.channel.allocator.buffer(capacity: 0)
            )
        case .body(var buffer):
            requestState?.bodyBuffer.writeBuffer(&buffer)
        case .end:
            guard let state = requestState else { return }
            requestState = nil

            nonisolated(unsafe) let ctx = context
            Task {
                await self.handleRequest(state: state, context: ctx)
            }
        }
    }

    private func handleRequest(state: RequestState, context: ChannelHandlerContext) async {
        let head = state.head
        let path = head.uri.split(separator: "?").first.map(String.init) ?? head.uri
        let endpoint = await listener.endpoint

        guard path == endpoint else {
            await writeResponse(
                .error(statusCode: 404, .invalidRequest("Not Found")),
                version: head.version,
                context: context
            )
            return
        }

        let httpRequest = makeHTTPRequest(from: state)
        let response = await listener.handleHTTPRequest(httpRequest)
        await writeResponse(response, version: head.version, context: context)
    }

    private func makeHTTPRequest(from state: RequestState) -> HTTPRequest {
        var headers: [String: String] = [:]
        for (name, value) in state.head.headers {
            if let existing = headers[name] {
                headers[name] = existing + ", " + value
            } else {
                headers[name] = value
            }
        }

        let body: Data?
        if state.bodyBuffer.readableBytes > 0,
           let bytes = state.bodyBuffer.getBytes(at: 0, length: state.bodyBuffer.readableBytes)
        {
            body = Data(bytes)
        } else {
            body = nil
        }

        return HTTPRequest(method: state.head.method.rawValue, headers: headers, body: body)
    }

    private func writeResponse(
        _ response: HTTPResponse,
        version: HTTPVersion,
        context: ChannelHandlerContext
    ) async {
        nonisolated(unsafe) let ctx = context
        let eventLoop = ctx.eventLoop

        let statusCode = response.statusCode
        let headers = response.headers
        let bodyData = response.bodyData

        eventLoop.execute {
            var head = HTTPResponseHead(
                version: version,
                status: HTTPResponseStatus(statusCode: statusCode)
            )
            for (name, value) in headers {
                head.headers.add(name: name, value: value)
            }

            ctx.write(self.wrapOutboundOut(.head(head)), promise: nil)

            if let body = bodyData {
                var buffer = ctx.channel.allocator.buffer(capacity: body.count)
                buffer.writeBytes(body)
                ctx.write(self.wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
            }

            ctx.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
        }
    }
}
