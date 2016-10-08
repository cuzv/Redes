//
//  BatchRequest.swift
//  Copyright (c) 2015-2016 Moch Xiao (http://mochxiao.com).
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

/// Once run multipart requests concurrently.
public struct BatchRequest: RequestSender {
    public let requests: [Requestable]
    internal let underlyings: [Alamofire.DataRequest]
    public init(requests: [Requestable]) {
        self.requests = requests
        
        initialize()
        
        underlyings = requests.map { (request: Requestable) -> Alamofire.DataRequest in
            return Alamofire.request(
                request.url,
                method: request.method.alamofireValue,
                parameters: request.bodies,
                encoding: request.encoding.alamofireValue,
                headers: request.headers
            )
        }
    }
    
    @discardableResult
    public func resume() -> BatchRequest {
        underlyings.forEach { (request: Alamofire.DataRequest) in
            request.resume()
        }
        return self
    }
    
    @discardableResult
    public func cancel() -> BatchRequest {
        underlyings.forEach { (request: Alamofire.DataRequest) in
            request.cancel()
        }
        return self
    }
    
    @discardableResult
    public func suspend() -> BatchRequest {
        underlyings.forEach { (request: Alamofire.DataRequest) in
            request.suspend()
        }
        return self
    }
}
