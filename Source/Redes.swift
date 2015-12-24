//
//  Redes.swift
//  Redes
//
//  Created by Moch Xiao on 11/3/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
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

/// T: protocol<Requestable, Responseable, Downloadable>
public func request<T: protocol<Requestable, Responseable, Downloadable>>(setup: T) -> Request {
    return Request(setup: setup)
}

/// Set up NSURLCache
/// Should invoke on `application:didFinishLaunchingWithOptions:`
public func setupSharedURLCache(memoryCapacity memoryCapacity: Int, diskCapacity: Int, diskPath: String? = nil) {
    NSURLCache.setSharedURLCache(NSURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: diskPath))
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