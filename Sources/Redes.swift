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
public func request<T: Requestable & Responseable>(_ setup: T) -> Request {
    return Request(setup: setup)
}

/// T: protocol<Requestable, Responseable, Uploadable>
public func request<T: Requestable & Responseable & Uploadable>(_ setup: T) -> Request {
    return Request(setup: setup)
}

/// T: protocol<Requestable, Responseable, MultipartUploadable>
public func request<T: Requestable & Responseable & MultipartUploadable>(_ setup: T) -> Request {
    return Request(setup: setup)
}

/// T: protocol<Requestable, Responseable, Downloadable>
public func request<T: Requestable & Responseable & Downloadable>(_ setup: T) -> Request {
    return Request(setup: setup)
}

/// Set up NSURLCache
/// Should invoke on `application:didFinishLaunchingWithOptions:`
public func setupSharedURLCache(memoryCapacity: Int, diskCapacity: Int) {
    URLCache.shared.memoryCapacity = memoryCapacity
    URLCache.shared.diskCapacity = diskCapacity
}

internal var RedesDebugModeEnabled = false
public func setupDebugModeEnable(_ enable: Bool) {
    RedesDebugModeEnabled = enable
}

// MARK: - Convenience request & response

public extension Requestable where Self: Responseable {
    /// Response
    public func response(
        queue: DispatchQueue? = nil,
        completionHandler:  @escaping (URLRequest?, HTTPURLResponse?, Data?, NSError?) -> ())
        -> Request
    {
        return Redes.request(self).response(
            queue: queue,
            completionHandler: completionHandler
        )
    }
    
    /// Resposne data
    public func responseData(
        queue: DispatchQueue? = nil,
        completionHandler:  @escaping (Result<Response, Data, NSError>) -> ())
        -> Request
    {
        return Redes.request(self).responseData(
            queue: queue,
            completionHandler: completionHandler
        )
    }

    /// Response strting data
    public func responseString(
        queue: DispatchQueue? = nil,
        encoding: String.Encoding? = nil,
        completionHandler:  @escaping (Result<Response, String, NSError>) -> ())
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
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        completionHandler:  @escaping (Result<Response, AnyObject, NSError>) -> ())
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
        queue: DispatchQueue? = nil,
        options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions(),
        completionHandler:  @escaping (Result<Response, AnyObject, NSError>) -> ())
        -> Request
    {
        return Redes.request(self).responsePropertyList(
            queue: queue,
            options: options,
            completionHandler: completionHandler
        )
    }
}

public extension Requestable where Self: Responseable {
    public func asyncResponseJSON(_ completionHandler:  @escaping (Result<Response, AnyObject, NSError>) -> ()) -> Request {
        return Redes.request(self).asyncResponseJSON(completionHandler)
    }
}

// MARK: - Resonse JSON asynchronous

public extension Redes.Request  {
    public func asyncResponseJSON(_ completionHandler:  @escaping (Result<Response, AnyObject, NSError>) -> ())
        -> Self
    {
        _ = responseJSON(queue: DispatchQueue.global(), completionHandler: completionHandler)
        return self
    }
}

public extension Redes.BatchRequest {
    public func asyncResponseJSON(_ completionHandler:  @escaping ([Result<Response, AnyObject, NSError>]) -> ())
        -> Self
    {
        _ = responseJSON(queue: DispatchQueue.global(), completionHandler: completionHandler)
        return self
    }
}
