//
//  Command.swift
//  Redes
//
//  Created by Moch Xiao on 11/7/15.
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
    
    /// bytesRead, totalBytesRead, totalBytesExpectedToRead
    func progress(closure: ((bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) -> Void)?)

}

