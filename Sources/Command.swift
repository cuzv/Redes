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
    func injectRequest(_ request: Request)
    /// Remove request
    func removeRequest()
    
    /// Response default
    func response(queue: DispatchQueue?, completionHandler: (URLRequest?, HTTPURLResponse?, Data?, NSError?) -> ())
    /// Response binary data
    func responseData(queue: DispatchQueue?, completionHandler: (Result<Response, Data, NSError>) -> ())
    /// Response string
    func responseString(queue: DispatchQueue?, encoding: String.Encoding?, completionHandler: (Result<Response, String, NSError>) -> ())
    /// Response JSON
    func responseJSON(queue: DispatchQueue?, options: JSONSerialization.ReadingOptions, completionHandler: (Result<Response, AnyObject, NSError>) -> ())
    /// Response PList
    func responsePropertyList(queue: DispatchQueue?, options: PropertyListSerialization.ReadOptions, completionHandler: (Result<Response, AnyObject, NSError>) -> ())
    
    /// bytesRead, totalBytesRead, totalBytesExpectedToRead
    func progress(_ closure: ((_ bytesRead: Int64, _ totalBytesRead: Int64, _ totalBytesExpectedToRead: Int64) -> Void)?)

}

