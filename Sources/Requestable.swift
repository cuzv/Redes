//
//  Requestable.swift
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

// MARK: - Requestable

public protocol Requestable {
    /// The request command, `AlamofireCommand` by default
    var requestCommand: Command { get }
    
    /// The request url string
    var requestURLPath: URLConvertible { get }

    /// The request method
    var requestMethod: Method { get }
    /// The request body parameters, empty by default
    var requestBodyParameters: [String: AnyObject] { get }
    /// The request header parameters, empty by default
    var requestHeaderParameters: [String: String] { get }
    /// The request parameter encoding, `.URL` by default
    var requestParameterEncoding: ParameterEncoding { get }
    /// The request timeout interval, `10` by default
    var requestTimeoutInterval: Double { get }
}

/// Implement the optional methods
public extension Requestable {
    var requestCommand: Command {
        return AlamofireCommand()
    }
    
    var requestMethod: HTTPMethod {
        return .get
    }

    var requestBodyParameters: [String: AnyObject] {
        return [:]
    }
    
    var requestHeaderParameters: [String: String] {
        return [:]
    }
    
    var requestParameterEncoding: ParameterEncoding {
        return .url
    }
    
    var requestTimeoutInterval: Double {
        return 10
    }
}

// MARK: - Uploadable

/// You must implement one of follow `uploadXXX` methods or `multipartFormData`.
public protocol Uploadable {
    /// Upload file
    var uploadFileURL: URL? { get }
    /// Upload binary date
    var uploadData: Data? { get }
    /// Upload stream
    var uploadStream: InputStream? { get }
}

public extension Uploadable {
    var uploadFileURL: URL? {
        return nil
    }
    
    var uploadData: Data? {
        return nil
    }
    
    var uploadStream: InputStream? {
        return nil
    }
    
    /// Helper func
    internal var isImplementedProtocolUploadable: Bool {
        if let _ = uploadFileURL {
            return true
        } else if let _ = uploadData {
            return true
        } else if let _ = uploadStream {
            return true
        }
        
        return false
    }
}

/// Multipart form data upload
public protocol MultipartUploadable {
    /// Upload multipart form data
    var multipartFormData: ((MultipartFormData) -> ()) { get }
    /// Upload multipart form data completion handler
    var completionHandler: ((Request) -> ()) { get }
    var encodingMemoryThreshold: UInt64 { get }
}

public extension MultipartUploadable {
    var encodingMemoryThreshold: UInt64 {
        return 1024*1024*50
    }
}

// MARK: - Downloadable

public protocol Downloadable {
    /// Downloaded resume data
    var resulmeData: Data? { get }
    /// File save location
    var destination: (_ temporaryURL: URL, _ response: HTTPURLResponse) -> URL { get }
}

public extension Downloadable {
    var resulmeData: Data? {
        return nil
    }
    
    var destination: (_ temporaryURL: URL, _ response: HTTPURLResponse) -> URL {
        return { (temporaryURL: URL, response: HTTPURLResponse) -> URL in
            if let suggestedDestination = response.suggestedDestination {
                return suggestedDestination
            }
            return temporaryURL
        }
    }
}

// AMRK: - Helpers

public extension HTTPURLResponse {
    public var suggestedDestination: URL? {
        let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if !directoryURLs.isEmpty, let suggestedFilename = self.suggestedFilename {
            let address = unsafeBitCast(Unmanaged.passUnretained(self).toOpaque(), to: Int.self)
            return directoryURLs[0].appendingPathComponent(String(address) + suggestedFilename)
        }
        return nil
    }
}

