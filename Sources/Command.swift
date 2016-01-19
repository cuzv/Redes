//
//  Command.swift
//  Redes
//
//  Created by Moch Xiao on 11/7/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation

public protocol Command: class {
    /// Add request
    func injectRequest(request: Request)
    /// Remove request
    func removeRequest()
    
    /// Response default
    func response(queue queue: dispatch_queue_t?, completionHandler: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> ())
    /// Response binary data
    func responseData(queue queue: dispatch_queue_t?, completionHandler: Result<Response, NSData, NSError> -> ())
    /// Response string
    func responseString(queue queue: dispatch_queue_t?, encoding: NSStringEncoding?, completionHandler: Result<Response, String, NSError> -> ())
    /// Response JSON
    func responseJSON(queue queue: dispatch_queue_t?, options: NSJSONReadingOptions, completionHandler: Result<Response, AnyObject, NSError> -> ())
    /// Response PList
    func responsePropertyList(queue queue: dispatch_queue_t?, options: NSPropertyListReadOptions, completionHandler: Result<Response, AnyObject, NSError> -> ())
}

