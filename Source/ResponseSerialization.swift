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
    /// Resposne data
    public func responseData(
        completionHandler: Result<Response, NSData, NSError> -> ())
        -> Self {
            command.responseData(completionHandler)
            return self
    }
    
    /// Response strting data
    public func responseString(
        encoding encoding: NSStringEncoding? = nil,
        completionHandler: Result<Response, String, NSError> -> ())
        -> Self
    {
        command.responseString(encoding: encoding, completionHandler: completionHandler)
        return self
    }

    /// Response json data
    public func responseJSON(
        options options: NSJSONReadingOptions = .AllowFragments,
        completionHandler: Result<Response, AnyObject, NSError> -> ())
        -> Self
    {
        command.responseJSON(options: options, completionHandler: completionHandler)
        return self
    }
    
    /// Response PList
    public func responsePropertyList(
        options options: NSPropertyListReadOptions = NSPropertyListReadOptions(),
        completionHandler: Result<Response, AnyObject, NSError> -> ())
        -> Self
    {
        command.responsePropertyList(options: options, completionHandler: completionHandler)
        return self
    }
}
