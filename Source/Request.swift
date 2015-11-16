//
//  Request.swift
//  Redes
//
//  Created by Moch Xiao on 11/4/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

final public class Request {
    internal var setup: protocol<Requestable, Responseable>
    public private(set) var command: Command
    
    deinit {
        debugPrint("Request deinit...")
    }
    
    init(setup: protocol<Requestable, Responseable>) {
        self.setup = setup
        self.command = setup.requestCommand
        sendCommand()
    }

    init(setup: protocol<Requestable, Responseable, Uploadable>) {
        self.setup = setup
        self.command = setup.requestCommand
        sendCommand()
    }
    
    init(setup: protocol<Requestable, Responseable, Downloadable>) {
        self.setup = setup
        self.command = setup.requestCommand
        sendCommand()
    }
    
    init(setup: protocol<Requestable, Responseable, Uploadable, Downloadable>) {
        self.setup = setup
        self.command = setup.requestCommand
        sendCommand()
    }
}

// MARK: - Send request & cancel request

public extension Request {
    /// Send the `start request` command
    private func sendCommand() {
        debugPrint(self)
        command.injectRequest(self)
    }
    
    /// Cancel the request
    public func cancel() {
        command.removeRequest()
    }
}

// MARK: - CustomStringConvertible

extension Request: CustomStringConvertible {
    /// The textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure.
    public var description: String {
        return debugDescription
    }
}

// MARK: - CustomDebugStringConvertible

extension Request: CustomDebugStringConvertible {
    /// The debug textual representation used when written to an output stream, which includes the URL request, the URL
    /// response, the server data and the response serialization result.
    public var debugDescription: String {
        var output: [String] = []
        output.append("-------------------------------------------------")
        output.append("requestURLPath: \(setup.requestURLPath)")
        output.append("requestMethod: \(setup.requestMethod)")
        output.append("requestHeaderParameters: \(setup.requestHeaderParameters)")
        output.append("requestBodyParameters: \(setup.requestBodyParameters)")
        output.append("-------------------------------------------------")        
        return output.joinWithSeparator("\n")
    }
}
