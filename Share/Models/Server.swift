//
//  Server.swift
//  Share
//
//  Created by Till Brügmann on 30.08.25.
//

import Foundation

import NIOTransportServices
import NIOHTTP1
import NIO

class Server {
    // MARK: - Initializers
    init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    // MARK: - Public functions
    func start() {
        do {
            let bootstrap = NIOTSListenerBootstrap(group: group)
                .childChannelInitializer { channel in
                    channel.pipeline.configureHTTPServerPipeline()
                        .flatMap {
                            channel.pipeline.addHandler(DummyHandler())
                        }
                }
            let channel = try bootstrap
                .bind(host: host, port: port)
                .wait()
            
            try channel.closeFuture.wait()
        } catch {
            print("An error happed \(error.localizedDescription)")
            exit(0)
        }
    }
    
    func stop() {
        do {
            try group.syncShutdownGracefully()
        } catch {
            print("An error happed \(error.localizedDescription)")
            exit(0)
        }
    }
    
    // MARK: - Private properties
    private let group = NIOTSEventLoopGroup()
    private var host: String
    private var port: Int
}

final class DummyHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let part = self.unwrapInboundIn(data)
        
        guard case .head = part else {
            return
        }
        
        // Prepare the response body
        let message = ["message": "Hello World"]
        let response = try! JSONEncoder().encode(message)
        
        // set the headers
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "Content-Length", value: "\(response.count)")
        
        let responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: headers)
        context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
        
        // Set the data
        var buffer = context.channel.allocator.buffer(capacity: response.count)
        buffer.writeBytes(response)
        let body = HTTPServerResponsePart.body(.byteBuffer(buffer))
        context.writeAndFlush(self.wrapOutboundOut(body), promise: nil)
    }
}
