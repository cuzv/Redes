//
//  Request.swift
//  Redes
//
//  Created by Moch Xiao on 9/30/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

import Foundation

// MARK: -

public struct DefaultDataResponse {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    public let error: Error?
    
    init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) {
        self.request = request
        self.response = response
        self.data = data
        self.error = error
    }
}

// MARK: -

public struct DataResponse<Value> {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    public let result: Result<Value>
    
    public init(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        result: Result<Value>)
    {
        self.request = request
        self.response = response
        self.data = data
        self.result = result
    }
}

// MARK: -

public protocol DataRequest: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    var url: URLConvertible { get }
    var headers: [String: String] { get }
    var bodies: [String: Any] { get }
    
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding { get }
}

public extension DataRequest {
    public var headers: [String: String] {
        return [:]
    }
    
    public var bodies: [String: Any] {
        return [:]
    }
    
    public var method: HTTPMethod {
        return .get
    }
    
    public var encoding: ParameterEncoding {
        return .url
    }
}

// MARK: - Hashable

public extension DataRequest {
    public var hashValue: Int {
        let size = MemoryLayout<Int>.size
        func rotate(value: Int, howmuch: Int) -> Int {
            return (value << howmuch) | (value >> (size - howmuch))
        }
        
        do {
            let url = try self.url.asURL()
            var hashValue = url.hashValue
            hashValue = rotate(value: hashValue, howmuch: size / 2) ^ headers.queryString.hashValue
            hashValue ^= rotate(value: hashValue, howmuch: size / 2) ^ bodies.queryString.hashValue
            return hashValue
        } catch {
            fatalError("url: \(url) can did not conforms`URLConvertible`.")
        }
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

// MARK: - CustomStringConvertible

extension DataRequest {
    /// The textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure.
    public var description: String {
        return debugDescription
    }
}

// MARK: - CustomDebugStringConvertible

extension DataRequest {
    /// The debug textual representation used when written to an output stream, which includes the URL request, the URL
    /// response, the server data and the response serialization result.
    public var debugDescription: String {
        var output: [String] = []
        output.append("-------------------------------------------------")
        output.append("requestURLPath: \(url)")
        output.append("requestMethod: \(method)")
        output.append("requestHeaderParameters: \(headers)")
        output.append("requestBodyParameters: \(bodies)")
        output.append("-------------------------------------------------")
        return output.joined(separator: "\n")
    }
}

// MARK: -

extension Dictionary {
    /// URL query string.
    fileprivate var queryString: String {
        return map { "\($0.0)=\($0.1)" }.sorted().joined(separator: "&")
    }
}

public protocol UploadRequest: DataRequest {
    
}

public protocol DownloadRequest: DataRequest {

}

