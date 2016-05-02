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

public class BatchRequest {
    public typealias Element = protocol<Requestable, Responseable>
    
    internal var setups: [Element]
    public private(set) var requests: [Request]

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
}

// MARK: - Response serialization

public extension BatchRequest {
    /// Response
    public func response(
        queue queue: dispatch_queue_t? = nil,
              completionHandler: [(NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?)] -> ())
        -> Self
    {
        var results: [(NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?)] = []
        let barrierQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
        let parseQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
        requests.forEach { (req: Request) in
            dispatch_barrier_async(barrierQueue) {
                let semaphore = dispatch_semaphore_create(0)
                req.response(queue: parseQueue) { (req: NSURLRequest?, rsp: NSHTTPURLResponse?, data: NSData?, error: NSError?) in
                    results.append((req, rsp, data, error))
                    dispatch_semaphore_signal(semaphore)
                }
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            }
        }
        
        dispatch_barrier_async(barrierQueue) {
            dispatch_async(queue ?? dispatch_get_main_queue()) {
                completionHandler(results)
            }
        }

        return self
    }

    /// Resposne data
    public func responseData(
        queue queue: dispatch_queue_t? = nil,
              completionHandler: [Result<Response, NSData, NSError>] -> ())
        -> Self
    {
        var results: [Result<Response, NSData, NSError>] = []
        let barrierQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
        let parseQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
        requests.forEach { (req: Request) in
            dispatch_barrier_async(barrierQueue) {
                let semaphore = dispatch_semaphore_create(0)
                req.responseData(queue: parseQueue) { (result: Result<Response, NSData, NSError>) in
                    results.append(result)
                    dispatch_semaphore_signal(semaphore)
                }
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            }
        }
        
        dispatch_barrier_async(barrierQueue) {
            dispatch_async(queue ?? dispatch_get_main_queue()) {
                completionHandler(results)
            }
        }

        return self
    }

    /// Response strting data
    public func responseString(
        queue queue: dispatch_queue_t? = nil,
              encoding: NSStringEncoding? = nil,
              completionHandler: [Result<Response, String, NSError>] -> ())
        -> Self
    {
        var results: [Result<Response, String, NSError>] = []
        let barrierQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
        let parseQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
        requests.forEach { (req: Request) in
            dispatch_barrier_async(barrierQueue) {
                let semaphore = dispatch_semaphore_create(0)
                req.responseString(queue: parseQueue, encoding: encoding) { (result: Result<Response, String, NSError>) in
                    results.append(result)
                    dispatch_semaphore_signal(semaphore)
                }
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            }
        }
        
        dispatch_barrier_async(barrierQueue) {
            dispatch_async(queue ?? dispatch_get_main_queue()) {
                completionHandler(results)
            }
        }
        
        return self
    }

    
    /// Response json data
    public func responseJSON(
        queue queue: dispatch_queue_t? = nil,
              options: NSJSONReadingOptions = .AllowFragments,
              completionHandler: [Result<Response, AnyObject, NSError>] -> ())
        -> Self
    {
        var results: [Result<Response, AnyObject, NSError>] = []
        let barrierQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
        let parseQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
        requests.forEach { (req: Request) in
            dispatch_barrier_async(barrierQueue) {
                let semaphore = dispatch_semaphore_create(0)
                req.responseJSON(queue: parseQueue, options: options) { (result: Result<Response, AnyObject, NSError>) in
                    results.append(result)
                    dispatch_semaphore_signal(semaphore)
                }
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            }
        }
        
        dispatch_barrier_async(barrierQueue) {
            dispatch_async(queue ?? dispatch_get_main_queue()) {
                completionHandler(results)
            }
        }
        
        return self
    }
    
    /// Response PList
    public func responsePropertyList(
        queue queue: dispatch_queue_t? = nil,
              options: NSPropertyListReadOptions = NSPropertyListReadOptions(),
              completionHandler: [Result<Response, AnyObject, NSError>] -> ())
        -> Self
    {
        var results: [Result<Response, AnyObject, NSError>] = []
        let barrierQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
        let parseQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
        requests.forEach { (req: Request) in
            dispatch_barrier_async(barrierQueue) {
                let semaphore = dispatch_semaphore_create(0)
                req.responsePropertyList(queue: parseQueue, options: options) { (result: Result<Response, AnyObject, NSError>) in
                    results.append(result)
                    dispatch_semaphore_signal(semaphore)
                }
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            }
        }
        
        dispatch_barrier_async(barrierQueue) {
            dispatch_async(queue ?? dispatch_get_main_queue()) {
                completionHandler(results)
            }
        }

        return self
    }

}