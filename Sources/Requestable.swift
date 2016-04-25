//
//  Requestable.swift
//  Redes
//
//  Created by Moch Xiao on 11/3/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Requestable

public protocol Requestable {
    /// The request command, `AlamofireCommand` by default
    var requestCommand: Command { get }
    
    /// The request url string
    var requestURLPath: URLStringConvertible { get }

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
    
    var requestMethod: Method {
        return .GET
    }

    var requestBodyParameters: [String: AnyObject] {
        return [:]
    }
    
    var requestHeaderParameters: [String: String] {
        return [:]
    }
    
    var requestParameterEncoding: ParameterEncoding {
        return .URL
    }
    
    var requestTimeoutInterval: Double {
        return 10
    }
}

// MARK: - Uploadable

/// You must implement one of follow `uploadXXX` methods or `multipartFormData`.
public protocol Uploadable {
    /// Upload file
    var uploadFileURL: NSURL? { get }
    /// Upload binary date
    var uploadData: NSData? { get }
    /// Upload stream
    var uploadStream: NSInputStream? { get }
}

public extension Uploadable {
    var uploadFileURL: NSURL? {
        return nil
    }
    
    var uploadData: NSData? {
        return nil
    }
    
    var uploadStream: NSInputStream? {
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
    var multipartFormData: (MultipartFormData -> ()) { get }
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
    /// Download file 
    /// NSData?: resume data
    var downloadDestinationTuple: (NSData?, DownloadFileDestination) { get }
}

public extension Downloadable {
}

