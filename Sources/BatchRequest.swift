//
//  BatchRequest.swift
//  Redes
//
//  Created by Moch Xiao on 10/7/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

public struct BatchRequest: RequestSender {
    public let requests: [Requestable]
    internal let underlyings: [Alamofire.DataRequest]
    public init(requests: [Requestable]) {
        self.requests = requests
        
        Alamofire.SessionManager.default.startRequestsImmediately = false
        
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
