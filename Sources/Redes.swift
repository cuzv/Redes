//
//  Redes.swift
//  Redes
//
//  Created by Moch Xiao on 11/3/15.
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

/// T: protocol<Requestable, Responseable>
public func request<T: protocol<Requestable, Responseable>>(setup: T) -> Request {
    return Request(setup: setup)
}

/// T: protocol<Requestable, Responseable, Uploadable>
public func request<T: protocol<Requestable, Responseable, Uploadable>>(setup: T) -> Request {
    return Request(setup: setup)
}

/// T: protocol<Requestable, Responseable, MultipartUploadable>
public func request<T: protocol<Requestable, Responseable, MultipartUploadable>>(setup: T) -> Request {
    return Request(setup: setup)
}

/// T: protocol<Requestable, Responseable, Downloadable>
public func request<T: protocol<Requestable, Responseable, Downloadable>>(setup: T) -> Request {
    return Request(setup: setup)
}

/// Set up NSURLCache
/// Should invoke on `application:didFinishLaunchingWithOptions:`
public func setupSharedURLCache(memoryCapacity memoryCapacity: Int, diskCapacity: Int, diskPath: String? = nil) {
    NSURLCache.setSharedURLCache(NSURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: diskPath))
}

internal var RedesDebugModeEnabled = false
public func setupDebugModeEnable(enable: Bool) {
    RedesDebugModeEnabled = enable
}

// MARK: - Convenience request & response

extension Requestable where Self: Responseable {
    /// Response
    public func response(
        queue queue: dispatch_queue_t? = nil,
        completionHandler: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> ())
        -> Request
    {
        return Redes.request(self).response(
            queue: queue,
            completionHandler: completionHandler
        )
    }
    
    /// Resposne data
    public func responseData(
        queue queue: dispatch_queue_t? = nil,
        completionHandler: Result<Response, NSData, NSError> -> ())
        -> Request
    {
        return Redes.request(self).responseData(
            queue: queue,
            completionHandler: completionHandler
        )
    }

    /// Response strting data
    public func responseString(
        queue queue: dispatch_queue_t? = nil,
        encoding: NSStringEncoding? = nil,
        completionHandler: Result<Response, String, NSError> -> ())
        -> Request
    {
        return Redes.request(self).responseString(
            queue: queue,
            encoding: encoding,
            completionHandler: completionHandler
        )
    }
    
    /// Response json data
    public func responseJSON(
        queue queue: dispatch_queue_t? = nil,
        options: NSJSONReadingOptions = .AllowFragments,
        completionHandler: Result<Response, AnyObject, NSError> -> ())
        -> Request
    {
        return Redes.request(self).responseJSON(
            queue: queue,
            options: options,
            completionHandler: completionHandler
        )
    }
    
    /// Response PList
    public func responsePropertyList(
        queue queue: dispatch_queue_t? = nil,
        options: NSPropertyListReadOptions = NSPropertyListReadOptions(),
        completionHandler: Result<Response, AnyObject, NSError> -> ())
        -> Request
    {
        return Redes.request(self).responsePropertyList(
            queue: queue,
            options: options,
            completionHandler: completionHandler
        )
    }
}