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
        completionHandler: Result<Response, NSData, NSError> -> Void)
        -> Request {
            command.responseData(completionHandler)
            return self
    }
    
    /// Response strting data
    public func responseString(
        encoding encoding: NSStringEncoding? = nil,
        completionHandler: Result<Response, String, NSError>-> Void)
        -> Request
    {
        command.responseString(encoding: encoding, completionHandler: completionHandler)
        return self
    }

    /// Response json data
    public func responseJSON(
        options options: NSJSONReadingOptions = .AllowFragments,
        completionHandler: Result<Response, AnyObject, NSError> -> Void)
        -> Request
    {
        command.responseJSON(options: options, completionHandler: completionHandler)
        return self
    }
    
    /// Response PList
    public func responsePropertyList(
        options options: NSPropertyListReadOptions = NSPropertyListReadOptions(),
        completionHandler: Result<Response, AnyObject, NSError> -> Void)
        -> Request
    {
        command.responsePropertyList(options: options, completionHandler: completionHandler)
        return self
    }
}
