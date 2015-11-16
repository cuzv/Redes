//
//  ResponseSerialization.swift
//  Redes
//
//  Created by Moch Xiao on 11/4/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Response serialization

public extension Request {
    /// Response
    public func response(
        queue queue: dispatch_queue_t? = nil,
        completionHandler: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> ())
        -> Self
    {
        command.response(queue: queue, completionHandler: completionHandler)
        return self
    }

    /// Resposne data
    public func responseData(
        queue queue: dispatch_queue_t? = nil,
        completionHandler: Result<Response, NSData, NSError> -> ())
        -> Self
    {
        command.responseData(queue: queue, completionHandler: completionHandler)
        return self
    }
    
    /// Response strting data
    public func responseString(
        queue queue: dispatch_queue_t? = nil,
        encoding: NSStringEncoding? = nil,
        completionHandler: Result<Response, String, NSError> -> ())
        -> Self
    {
        command.responseString(queue: queue, encoding: encoding, completionHandler: completionHandler)
        return self
    }

    /// Response json data
    public func responseJSON(
        queue queue: dispatch_queue_t? = nil,
        options: NSJSONReadingOptions = .AllowFragments,
        completionHandler: Result<Response, AnyObject, NSError> -> ())
        -> Self
    {
        command.responseJSON(queue: queue, options: options, completionHandler: completionHandler)
        return self
    }
    
    /// Response PList
    public func responsePropertyList(
        queue queue: dispatch_queue_t? = nil,
        options: NSPropertyListReadOptions = NSPropertyListReadOptions(),
        completionHandler: Result<Response, AnyObject, NSError> -> ())
        -> Self
    {
        command.responsePropertyList(queue: queue, options: options, completionHandler: completionHandler)
        return self
    }
}
