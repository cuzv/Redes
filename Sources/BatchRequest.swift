//
//  BatchRequest.swift
//  Redes
//
//  Created by Moch Xiao on 5/1/16.
//  Copyright © 2016 Moch Xiao (http://mochxiao.com).
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

open class BatchRequest {
    public typealias Element = Requestable & Responseable
    
    internal var setups: [Element]
    open fileprivate(set) var requests: [Request]

    deinit {
        if RedesDebugModeEnabled {
            debugPrint("BatchRequest deinit...")
        }
    }

    public init(setups: [Element]) {
        self.setups = setups
        self.requests = setups.map { (setup: Element) -> Request in
            return Redes.Request(setup: setup)
        }
    }
    
    fileprivate func makeBarrierQueue() -> DispatchQueue {
        return DispatchQueue(label: "com.mochxiao.redes.batchrequest.barrierqueue")
    }
    
    fileprivate func makeParseQueue() -> DispatchQueue {
        return DispatchQueue(label: "com.mochxiao.redes.batchrequest.parsequeue")
    }
}

// MARK: - Response serialization

public extension BatchRequest {
    /// Response
    public func response(
        queue: DispatchQueue? = nil,
              completionHandler: @escaping ([(URLRequest?, HTTPURLResponse?, Data?, NSError?)]) -> ())
        -> Self
    {
        var results: [(URLRequest?, HTTPURLResponse?, Data?, NSError?)] = []
        
        let barrierQueue = makeBarrierQueue()
        let parseQueue = makeParseQueue()
        requests.forEach { (req: Request) in
            barrierQueue.async(flags: .barrier, execute: {
                let semaphore = DispatchSemaphore(value: 0)
                req.response(queue: parseQueue) { (req: URLRequest?, rsp: HTTPURLResponse?, data: Data?, error: NSError?) in
                    results.append((req, rsp, data, error))
                    semaphore.signal()
                }
                semaphore.wait(timeout: DispatchTime.distantFuture)
            }) 
        }
        
        barrierQueue.async(flags: .barrier, execute: {
            (queue ?? DispatchQueue.main).async {
                completionHandler(results)
            }
        }) 

        return self
    }

    /// Resposne data
    public func responseData(
        queue: DispatchQueue? = nil,
              completionHandler: @escaping ([Result<Response, Data, NSError>]) -> ())
        -> Self
    {
        var results: [Result<Response, Data, NSError>] = []
        let barrierQueue = makeBarrierQueue()
        let parseQueue = makeParseQueue()
        requests.forEach { (req: Request) in
            barrierQueue.async(flags: .barrier, execute: {
                let semaphore = DispatchSemaphore(value: 0)
                req.responseData(queue: parseQueue) { (result: Result<Response, Data, NSError>) in
                    results.append(result)
                    semaphore.signal()
                }
                semaphore.wait(timeout: DispatchTime.distantFuture)
            }) 
        }
        
        barrierQueue.async(flags: .barrier, execute: {
            (queue ?? DispatchQueue.main).async {
                completionHandler(results)
            }
        }) 

        return self
    }

    /// Response strting data
    public func responseString(
        queue: DispatchQueue? = nil,
              encoding: String.Encoding? = nil,
              completionHandler: @escaping ([Result<Response, String, NSError>]) -> ())
        -> Self
    {
        var results: [Result<Response, String, NSError>] = []
        let barrierQueue = makeBarrierQueue()
        let parseQueue = makeParseQueue()
        requests.forEach { (req: Request) in
            barrierQueue.async(flags: .barrier, execute: {
                let semaphore = DispatchSemaphore(value: 0)
                req.responseString(queue: parseQueue, encoding: encoding) { (result: Result<Response, String, NSError>) in
                    results.append(result)
                    semaphore.signal()
                }
                semaphore.wait(timeout: DispatchTime.distantFuture)
            }) 
        }
        
        barrierQueue.async(flags: .barrier, execute: {
            (queue ?? DispatchQueue.main).async {
                completionHandler(results)
            }
        }) 
        
        return self
    }

    
    /// Response json data
    public func responseJSON(
        queue: DispatchQueue? = nil,
              options: JSONSerialization.ReadingOptions = .allowFragments,
              completionHandler: @escaping ([Result<Response, AnyObject, NSError>]) -> ())
        -> Self
    {
        var results: [Result<Response, AnyObject, NSError>] = []
        let barrierQueue = makeBarrierQueue()
        let parseQueue = makeParseQueue()
        requests.forEach { (req: Request) in
            barrierQueue.async(flags: .barrier, execute: {
                let semaphore = DispatchSemaphore(value: 0)
                req.responseJSON(queue: parseQueue, options: options) { (result: Result<Response, AnyObject, NSError>) in
                    results.append(result)
                    semaphore.signal()
                }
                semaphore.wait(timeout: DispatchTime.distantFuture)
            }) 
        }
        
        barrierQueue.async(flags: .barrier, execute: {
            (queue ?? DispatchQueue.main).async {
                completionHandler(results)
            }
        }) 
        
        return self
    }
    
    /// Response PList
    public func responsePropertyList(
        queue: DispatchQueue? = nil,
              options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions(),
              completionHandler: @escaping ([Result<Response, AnyObject, NSError>]) -> ())
        -> Self
    {
        var results: [Result<Response, AnyObject, NSError>] = []
        let barrierQueue = makeBarrierQueue()
        let parseQueue = makeParseQueue()
        requests.forEach { (req: Request) in
            barrierQueue.async(flags: .barrier, execute: {
                let semaphore = DispatchSemaphore(value: 0)
                req.responsePropertyList(queue: parseQueue, options: options) { (result: Result<Response, AnyObject, NSError>) in
                    results.append(result)
                    semaphore.signal()
                }
                semaphore.wait(timeout: DispatchTime.distantFuture)
            }) 
        }
        
        barrierQueue.async(flags: .barrier, execute: {
            (queue ?? DispatchQueue.main).async {
                completionHandler(results)
            }
        }) 

        return self
    }

}
