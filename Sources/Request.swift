//
//  Request.swift
//  Redes
//
//  Created by Moch Xiao on 11/4/15.
//  Copyright © 2015 Moch Xiao (http://mochxiao.com).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Alamofire

final public class Request {
    internal var setup: Requestable & Responseable
    public fileprivate(set) var command: Command
    /// Default `false`, means network could reach
    internal var networkUnavailable: Bool
        
    deinit {
        if RedesDebugModeEnabled {
            debugPrint("Request deinit...")
        }
    }
    
    init(setup: Requestable & Responseable) {
        networkUnavailable = false
        self.setup = setup
        self.command = setup.requestCommand
        sendCommand()
    }

    init(setup: Requestable & Responseable & Uploadable) {
        networkUnavailable = false
        self.setup = setup
        self.command = setup.requestCommand
        sendCommand()
    }
    
    init(setup: Requestable & Responseable & MultipartUploadable) {
        networkUnavailable = false
        self.setup = setup
        self.command = setup.requestCommand
        sendCommand()
    }
    
    init(setup: Requestable & Responseable & Downloadable) {
        networkUnavailable = false
        self.setup = setup
        self.command = setup.requestCommand
        sendCommand()
    }
}

// MARK: - Send request & cancel request

public extension Request {
    /// Send the `start request` command
    fileprivate func sendCommand() {
        if RedesDebugModeEnabled {
            debugPrint(self)
        }
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
        return output.joined(separator: "\n")
    }
}


// MARK: - Response serialization

public extension Request {
    /// Response
    public func response(
        queue: DispatchQueue? = nil,
              completionHandler: @escaping (URLRequest?, HTTPURLResponse?, Data?, NSError?) -> ())
        -> Self
    {
        command.response(queue: queue, completionHandler: completionHandler)
        return self
    }
    
    /// Resposne data
    public func responseData(
        queue: DispatchQueue? = nil,
              completionHandler:  @escaping (Result<Response, Data, NSError>) -> ())
        -> Self
    {
        command.responseData(queue: queue, completionHandler: completionHandler)
        return self
    }
    
    /// Response strting data
    public func responseString(
        queue: DispatchQueue? = nil,
              encoding: String.Encoding? = nil,
              completionHandler:  @escaping (Result<Response, String, NSError>) -> ())
        -> Self
    {
        command.responseString(queue: queue, encoding: encoding, completionHandler: completionHandler)
        return self
    }
    
    /// Response json data
    public func responseJSON(
        queue: DispatchQueue? = nil,
              options: JSONSerialization.ReadingOptions = .allowFragments,
              completionHandler:  @escaping (Result<Response, AnyObject, NSError>) -> ())
        -> Self
    {
        command.responseJSON(queue: queue, options: options, completionHandler: completionHandler)
        return self
    }
    
    /// Response PList
    public func responsePropertyList(
        queue: DispatchQueue? = nil,
              options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions(),
              completionHandler:  @escaping (Result<Response, AnyObject, NSError>) -> ())
        -> Self
    {
        command.responsePropertyList(queue: queue, options: options, completionHandler: completionHandler)
        return self
    }
    
    public func progress(_ closure: ((_ bytesRead: Int64, _ totalBytesRead: Int64, _ totalBytesExpectedToRead: Int64) -> Void)?) -> Self {
        command.progress(closure)
        return self
    }
}
