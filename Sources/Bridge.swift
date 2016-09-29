//
//  Bridge.swift
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

/// Let client separate from `Alamofire`

// MARK: - URLStringConvertible

public protocol URLConvertible: Alamofire.URLConvertible {
}

extension String: URLConvertible {
//    /// Returns a URL if `self` represents a valid URL string that conforms to RFC 2396 or throws an `AFError`.
//    ///
//    /// - throws: An `AFError.invalidURL` if `self` is not a valid URL string.
//    ///
//    /// - returns: A URL or throws an `AFError`.
//    public func asURL() throws -> URL {
//        guard let url = URL(string: self) else { throw AFError.invalidURL(url: self) }
//        return url
//    }
}

extension URL: URLConvertible {
    /// Returns self.
//    public func asURL() throws -> URL { return self }
}

extension URLComponents: URLConvertible {
//    /// Returns a URL if `url` is not nil, otherise throws an `Error`.
//    ///
//    /// - throws: An `AFError.invalidURL` if `url` is `nil`.
//    ///
//    /// - returns: A URL or throws an `AFError`.
//    public func asURL() throws -> URL {
//        guard let url = url else { throw AFError.invalidURL(url: self) }
//        return url
//    }
}


// MARK: - URLRequestConvertible

public protocol URLRequestConvertible: Alamofire.URLRequestConvertible {
}

extension Foundation.URLRequest: URLRequestConvertible {
//    /// Returns a URL request or throws if an `Error` was encountered.
//    public func asURLRequest() throws -> URLRequest { return self }
}

// MARK: - typealias

public typealias MultipartFormData = Alamofire.MultipartFormData

// MARK:

/// HTTP method.
public enum HTTPMethod {
    case get, post, put, delete, options, head, patch, trace, connect
    
    /// Convert `Redes.Method` to `Alamofire.Method`
    func value() -> Alamofire.HTTPMethod {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        case .head:
            return .head
        case .options:
            return .options
        case .patch:
            return .patch
        case .trace:
            return .trace
        case .connect:
            return .connect
        }
    }
}

/// Parameter encoding
public enum ParameterEncoding {
    case url
    case urlEncodedInURL
    case json
    case propertyList(PropertyListSerialization.PropertyListFormat, PropertyListSerialization.WriteOptions)
//    case custom((URLRequestConvertible, [String: AnyObject]?) -> (NSMutableURLRequest, NSError?))
    
    /// Convert `Redes.ParameterEncoding` to `Alamofire.ParameterEncoding`
    func parameterEncoding() -> Alamofire.ParameterEncoding {
        switch self {
        case .url:
            return Alamofire.URLEncoding.default
        case .urlEncodedInURL:
            return Alamofire.URLEncoding.queryString
        case .json:
            return Alamofire.JSONEncoding.default
        case .propertyList(let format, let options):
            return Alamofire.PropertyListEncoding(format: format, options: options)
//        case .custom(let closure):
//            // `Redes` URLRequestConvertible inherit from `Alamofire.URLRequestConvertible`
//            return .custom(closure as! (Alamofire.URLRequestConvertible, [String: AnyObject]?) -> (NSMutableURLRequest, NSError?))
        }
    }
}

internal extension Error {
    static func redes_errorWithCode(_ code: Int, failureReason: String) -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        return NSError(domain: "com.mochxiao.redes.error", code: code, userInfo: userInfo)
    }
}
