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
    
    /// Response binary data
    func responseData(completionHandler: Result<Response, NSData, NSError> -> Void)
    /// Response string
    func responseString(encoding encoding: NSStringEncoding?, completionHandler: Result<Response, String, NSError> -> Void)
    /// Response JSON
    func responseJSON(options options: NSJSONReadingOptions, completionHandler: Result<Response, AnyObject, NSError> -> Void)
    /// Response PList
    func responsePropertyList(options options: NSPropertyListReadOptions, completionHandler: Result<Response, AnyObject, NSError> -> Void)
}

