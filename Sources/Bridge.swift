//
//  Bridge.swift
//  Redes
//
//  Created by Moch Xiao on 11/3/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

/// Let client separate from `Alamofire`

// MARK: - URLStringConvertible

public protocol URLStringConvertible: Alamofire.URLStringConvertible {
}

extension String: URLStringConvertible {
    public var URLString: String {
        return self
    }
}

extension NSURL: URLStringConvertible {
    public var URLString: String {
        return absoluteString
    }
}

extension NSURLComponents: URLStringConvertible {
    public var URLString: String {
        return URL!.URLString
    }
}

extension NSURLRequest: URLStringConvertible {
    public var URLString: String {
        return URL!.URLString
    }
}

// MARK: - URLRequestConvertible

public protocol URLRequestConvertible: Alamofire.URLRequestConvertible {
}

extension NSURLRequest: URLRequestConvertible {
    public var URLRequest: NSMutableURLRequest {
        return self.mutableCopy() as! NSMutableURLRequest
    }
}

// MARK: - typealias

public typealias MultipartFormData = Alamofire.MultipartFormData
public typealias MultipartFormDataEncodingResult = Alamofire.Manager.MultipartFormDataEncodingResult
public let MultipartFormDataEncodingMemoryThreshold: UInt64 = Alamofire.Manager.MultipartFormDataEncodingMemoryThreshold

public typealias DownloadFileDestination = Alamofire.Request.DownloadFileDestination

// MARK:

/// HTTP method.
public enum Method {
    case GET, POST, PUT, DELETE, OPTIONS, HEAD, PATCH, TRACE, CONNECT
    
    /// Convert `Redes.Method` to `Alamofire.Method`
    func method() -> Alamofire.Method {
        switch self {
        case .GET:
            return .GET
        case .POST:
            return .POST
        case .PUT:
            return .PUT
        case .DELETE:
            return .DELETE
        case .HEAD:
            return .HEAD
        case .OPTIONS:
            return .OPTIONS
        case PATCH:
            return .PATCH
        case TRACE:
            return .TRACE
        case .CONNECT:
            return .CONNECT
        }
    }
}

/// Parameter encoding
public enum ParameterEncoding {
    case URL
    case URLEncodedInURL
    case JSON
    case PropertyList(NSPropertyListFormat, NSPropertyListWriteOptions)
    case Custom((URLRequestConvertible, [String: AnyObject]?) -> (NSMutableURLRequest, NSError?))
    
    /// Convert `Redes.ParameterEncoding` to `Alamofire.ParameterEncoding`
    func parameterEncoding() -> Alamofire.ParameterEncoding {
        switch self {
        case .URL:
            return .URL
        case .URLEncodedInURL:
            return .URLEncodedInURL
        case .JSON:
            return .JSON
        case .PropertyList(let format, let options):
            return .PropertyList(format, options)
        case .Custom(let closure):
            // `Redes` URLRequestConvertible inherit from `Alamofire.URLRequestConvertible`
            return .Custom(closure as! (Alamofire.URLRequestConvertible, [String: AnyObject]?) -> (NSMutableURLRequest, NSError?))
        }
    }
}