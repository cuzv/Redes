//
//  Request.swift
//  Redes
//
//  Created by Moch Xiao on 9/30/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

func initialize() {
    Alamofire.SessionManager.default.startRequestsImmediately = false
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 10
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = 10
}

// MARK: - Requestable

public typealias HTTPHeaders = [String: String]
public typealias HTTPBodies = [String: Any]

public protocol Requestable: CustomStringConvertible, CustomDebugStringConvertible {
    var url: URLConvertible { get }
    var headers: HTTPHeaders { get }
    var bodies: HTTPBodies { get }
    
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding { get }
}

public extension Requestable {
    public var headers: HTTPHeaders {
        return [:]
    }
    
    public var bodies: HTTPBodies {
        return [:]
    }
    
    public var method: HTTPMethod {
        return .get
    }
    
    public var encoding: ParameterEncoding {
        return .url
    }
}

extension Requestable {
    
    /// The textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure.
    public var description: String {
        return debugDescription
    }
    
    /// The debug textual representation used when written to an output stream, which includes the URL request, the URL
    /// response, the server data and the response serialization result.
    public var debugDescription: String {
        var output: [String] = []
        output.append("-------------------------------------------------")
        output.append("requestURLPath: \(url)")
        output.append("requestMethod: \(method)")
        output.append("requestHeaderParameters: \(headers.prettyDescription)")
        output.append("requestBodyParameters: \(bodies.prettyDescription)")
        output.append("-------------------------------------------------")
        return output.joined(separator: "\n")
    }
}

extension Dictionary {
    var prettyDescription: String {
        var output = "[\n"
        output.append(map { "\t\($0.0): \($0.1)," }.sorted().joined(separator: "\n"))
        output.append("\n]")
        return output
    }
}

// MARK: - DataRequest

public protocol RequestSender {
    func resume() -> Self
    func cancel() -> Self
    func suspend() -> Self
}

public typealias ProgressHandler = (Progress) -> ()

public protocol DataRequestSender: RequestSender {
    /// The progress of fetching the response data from the server for the request.
    var progress: Progress { get}
    
    /// Sets a closure to be called periodically during the lifecycle of the `Request` as data is read from the server.
    ///
    /// - parameter queue:   The dispatch queue to execute the closure on.
    /// - parameter closure: The code to be executed periodically as data is read from the server.
    ///
    /// - returns: The request.
    func downloadProgress(queue: DispatchQueue, closure: @escaping ProgressHandler) -> Self
}

public struct DataRequest: DataRequestSender {
    public let request: Requestable
    internal let underlying: Alamofire.DataRequest
    public init(request: Requestable) {
        self.request = request
        
        initialize()
        
        underlying = Alamofire.request(
            request.url,
            method: request.method.alamofireValue,
            parameters: request.bodies,
            encoding: request.encoding.alamofireValue,
            headers: request.headers
        )
    }
    
    @discardableResult
    public func resume() -> DataRequest {
        underlying.resume()
        return self
    }
    
    @discardableResult
    public func cancel() -> DataRequest {
        underlying.cancel()
        return self
    }
    
    @discardableResult
    public func suspend() -> DataRequest {
        underlying.suspend()
        return self
    }
    
    /// The progress of fetching the response data from the server for the request.
    public var progress: Progress {
        return underlying.progress
    }
    
    /// Sets a closure to be called periodically during the lifecycle of the `Request` as data is read from the server.
    ///
    /// - parameter queue:   The dispatch queue to execute the closure on.
    /// - parameter closure: The code to be executed periodically as data is read from the server.
    ///
    /// - returns: The request.
    @discardableResult
    public func downloadProgress(queue: DispatchQueue = DispatchQueue.main, closure: @escaping ProgressHandler) -> DataRequest {
        underlying.downloadProgress(queue: queue, closure: closure)
        return self
    }
}

// MARK: - UploadRequest

public enum UploadElement {
    case file(URL)
    case data(Data)
    case inputStream(InputStream)
}

public protocol Uploadable: Requestable {
    var element: UploadElement { get }
}

public protocol UploadRequestSender: RequestSender {
    var uploadProgress: Progress { get }
    func uploadProgress(queue: DispatchQueue, closure: @escaping ProgressHandler) -> Self
}

public struct UploadRequest: UploadRequestSender {
    public let request: Uploadable
    public let underlying: Alamofire.UploadRequest
    public init(request: Uploadable) {
        self.request = request
        
        initialize()
        
        switch request.element {
        case .file(let url):
            underlying = Alamofire.upload(url, to: request.url, method: request.method.alamofireValue, headers: request.headers)
        case .data(let data):
            underlying = Alamofire.upload(data, to: request.url, method: request.method.alamofireValue, headers: request.headers)
        case .inputStream(let stream):
            underlying = Alamofire.upload(stream, to: request.url, method: request.method.alamofireValue, headers: request.headers)
        }
    }

    @discardableResult
    public func resume() -> UploadRequest {
        underlying.resume()
        return self
    }
    
    @discardableResult
    public func cancel() -> UploadRequest {
        underlying.cancel()
        return self
    }
    
    @discardableResult
    public func suspend() -> UploadRequest {
        underlying.suspend()
        return self
    }
    
    public var uploadProgress: Progress {
        return underlying.uploadProgress
    }
    
    @discardableResult
    public func uploadProgress(queue: DispatchQueue = DispatchQueue.main, closure: @escaping ProgressHandler) -> UploadRequest {
        underlying.uploadProgress(queue: queue, closure: closure)
        return self
    }
}

// MARK: - MultipartUploadRequest

public struct MultipartUploadElement {
    public let name: String
    public let filename: String
    public let mimeType: String
    public let raw: UploadElement
    
    /// Only work when raw is `.inputStream`
    public let length: UInt64
    public init(name: String, filename: String, mimeType: String, raw: UploadElement, length: UInt64 = 0) {
        self.name = name
        self.filename = filename
        self.mimeType = mimeType
        self.raw = raw
        self.length = length
    }
}

public protocol MultipartUploadable: Requestable {
    var elements: [MultipartUploadElement] { get }
    
    /// Default memory threshold used when encoding `MultipartFormData` in bytes.
    /// Default value is 10_000_000
    var threshold: UInt64 { get }
}

public extension MultipartUploadable {
    var threshold: UInt64 { return 10_000_000 }
}

public class MultipartUploadRequest {
    public let request: MultipartUploadable
    public init(request: MultipartUploadable) {
        self.request = request
        initialize()
    }
    
    public enum Result {
        case success(Alamofire.UploadRequest)
        case failure(Error)
    }
    public private(set) var result: Result?
    
    /// Note: Response func should invoke in handler closure.
    public func resume(handler: @escaping (MultipartUploadRequest) -> ()) {
        Alamofire.upload(multipartFormData: { (formData: MultipartFormData) in
            for element in self.request.elements {
                switch element.raw {
                case .file(let url):
                    formData.append(url, withName: element.name, fileName: element.filename, mimeType: element.mimeType)
                case .data(let data):
                    formData.append(data, withName: element.name, fileName: element.filename, mimeType: element.mimeType)
                case .inputStream(let stream):
                    formData.append(stream, withLength: element.length, name: element.filename, fileName: element.filename, mimeType: element.mimeType)
                }
            }
        }, usingThreshold: request.threshold, to: request.url, method: request.method.alamofireValue, headers: request.headers) { (result: SessionManager.MultipartFormDataEncodingResult) in
            switch result {
            case .success(request: let request, streamingFromDisk: _, streamFileURL: _):
                self.result = Result.success(request)
            case .failure(let error):
                self.result = Result.failure(error)
            }
            
            handler(self)
        }
    }
}

// MARK: - DownloadRequest

public protocol Downloadable: Requestable {
    /// Downloaded resume data
    var resulmeData: Data? { get }
    /// File save location
    var destination: (URL, HTTPURLResponse) -> URL { get }
}

public extension Downloadable {
    public var resulmeData: Data? {
        return nil
    }
    
    public var destination: (URL, HTTPURLResponse) -> URL {
        return { (temporaryURL, response) -> URL in
            if let suggestedDestination = response.suggestedDestination {
                return suggestedDestination
            }
            return temporaryURL
        }
    }
}

extension HTTPURLResponse {
    var suggestedDestination: URL? {
        let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if !directoryURLs.isEmpty {
            let dir = directoryURLs[0].appendingPathComponent("RedesDownloads", isDirectory: true)
            if let suggestedFilename = suggestedFilename {
                return dir.appendingPathComponent(suggestedFilename)
            } else {
                let address = unsafeBitCast(self, to: Int.self)
                return dir.appendingPathComponent(String(address) + "." + (mimeType?.components(separatedBy: "/").last ?? "dl"))
            }
        }
        return nil
    }
}

public protocol DownloadRequestSender: RequestSender {
    var downloadProgress: Progress { get }
    func downloadProgress(queue: DispatchQueue, closure: @escaping ProgressHandler) -> Self
}

public struct DownloadRequest: DownloadRequestSender {
    public let request: Downloadable
    public let underlying: Alamofire.DownloadRequest
    public init(request: Downloadable) {
        self.request = request
        
        initialize()
        
        let destination: Alamofire.DownloadRequest.DownloadFileDestination = { (url, response) in
            return (request.destination(url, response), [.removePreviousFile, .createIntermediateDirectories])
        }
        
        if let resumeData = request.resulmeData {
            underlying = Alamofire.download(resumingWith: resumeData, to: destination)
        } else {
            underlying = Alamofire.download(
                request.url,
                method: request.method.alamofireValue,
                parameters: request.bodies,
                encoding: request.encoding.alamofireValue,
                headers: request.headers,
                to: destination
            )
        }
    }
    
    @discardableResult
    public func resume() -> DownloadRequest {
        underlying.resume()
        return self
    }
    
    @discardableResult
    public func cancel() -> DownloadRequest {
        underlying.cancel()
        return self
    }
    
    @discardableResult
    public func suspend() -> DownloadRequest {
        underlying.suspend()
        return self
    }
    
    public var downloadProgress: Progress {
        return underlying.progress
    }
    
    @discardableResult
    public func downloadProgress(queue: DispatchQueue = DispatchQueue.main, closure: @escaping ProgressHandler) -> DownloadRequest {
        underlying.downloadProgress(queue: queue, closure: closure)
        return self
    }
}
