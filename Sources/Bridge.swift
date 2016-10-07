//
//  Bridge.swift
//  Redes
//
//  Created by Moch Xiao on 10/6/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

// MARK: -

public protocol URLConvertible: Alamofire.URLConvertible {
}

extension String: URLConvertible {
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw AFError.invalidURL(url: self) }
        return url
    }
}

public enum HTTPMethod {
    case options
    case get
    case head
    case post
    case put
    case patch
    case delete
    case trace
    case connect
    
    var alamofireValue: Alamofire.HTTPMethod {
        switch self {
        case .options:
            return .options
        case .get:
            return .get
        case .head:
            return .head
        case .post:
            return .post
        case .put:
            return .put
        case .patch:
            return .patch
        case .delete:
            return .delete
        case .trace:
            return .trace
        case .connect:
            return .connect
        }
    }
}

public enum ParameterEncoding {
    case url
    case json
    case xml
}

extension ParameterEncoding {
    var alamofireValue: Alamofire.ParameterEncoding {
        return URLEncoding.default
    }
}

