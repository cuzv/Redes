//
//  Request.swift
//  Redes
//
//  Created by Moch Xiao on 9/30/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

public protocol URLConvertible: Alamofire.URLConvertible {
}

public typealias HTTPMethod = Alamofire.HTTPMethod

public enum ParameterEncoding {
    case url
    case json
    case xml
}

extension ParameterEncoding {
    var AalamofireParameterEncoding: Alamofire.ParameterEncoding {
        return URLEncoding.default
    }
}

public protocol Request {
    var url: URLConvertible { get }
    var headers: [String: String] { get }
    var bodies: [String: Any] { get }
    
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding { get }
}

extension Request {
    var method: HTTPMethod {
        return .get
    }
    
    var parameterEncoding: ParameterEncoding {
        return .url
    }
}

public struct ParsedData {
    public let code: Int
    public let message: String
    public let data: Any
}

public protocol Parsable {
    /// Parse data from server response
    ///
    /// - parameter data: the data server responsed
    ///
    /// - throws: RedesError
    ///
    /// - returns: ParsedData
    func parsing(data: Any) throws -> ParsedData
}

public protocol UploadRequest: Request {
    
}

public protocol DownloadRequest: Request {

}

public protocol RequestSender {
    func send<T: Request & Parsable>(_ request: T) -> T
}

