//
//  RedesRequestSender.swift
//  Redes
//
//  Created by Moch Xiao on 9/30/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire








public protocol RequestSender {
    func add<T: DataRequest>(_ request: T) -> T
    func remove<T: DataRequest>(_ request: T) -> T
    func suspend<T: DataRequest>(_ request: T) -> T
}

public class RedesRequestSender: RequestSender {
    internal static let shared: RedesRequestSender = RedesRequestSender()
    internal var requestPairs: [AnyHashable : Any] = [:]
    
    public func add<T: DataRequest>(_ request: T) -> T {
        let req = Alamofire.request(
            request.url,
            method: request.method.alamofireValue,
            parameters: request.bodies,
            encoding: request.encoding.alamofireValue,
            headers: request.headers
        )

        requestPairs.updateValue(req, forKey: request)
        let op = BlockOperation {
            _ = self.requestPairs.removeValue(forKey: request)
        }
        req.delegate.queue.addOperations([op], waitUntilFinished: true)
        
        
        debugPrint("requestPairs.count: \((requestPairs.count))")
        
        return request
    }
    
    public func remove<T: DataRequest>(_ request: T) -> T {
        if let value = requestPairs.removeValue(forKey: request) as? Alamofire.DataRequest {
            value.cancel()
            requestPairs.removeValue(forKey: request)
        }
        return request
    }
    
    public func suspend<T: DataRequest>(_ request: T) -> T {
        if let value = requestPairs.removeValue(forKey: request) as? Alamofire.DataRequest {
            value.suspend()
        }
        return request
    }

}
