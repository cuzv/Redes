//
//  Response.swift
//  Redes
//
//  Created by Moch Xiao on 11/4/15.
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

public struct Response {
    /// The request sent to the server.
    public let originalSetup: Requestable & Responseable
    /// The data returned by the server.
    public let data: Data?
    /// The server's response to the URL request.
    public let URLResponse: HTTPURLResponse?
    /// The message returned by the server or constructed internal.
    public let message: String?
    /// The status code returned by the server or constructed internal.
    public let statusCode: Int?

    public init(
        setup: Requestable & Responseable,
        data: Data?,
        response: HTTPURLResponse?,
        message: String?,
        statusCode: Int?)
    {
        originalSetup = setup
        self.data = data
        self.URLResponse = response
        self.message = message
        self.statusCode = statusCode
    }
}
