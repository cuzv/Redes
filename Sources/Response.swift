//
//  Response.swift
//  Copyright (c) 2015-2016 Moch Xiao (http://mochxiao.com).
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

// MARK: -

/// Used to store all data associated with an non-serialized response of a data or upload request.
public struct DefaultDataResponse: CustomStringConvertible, CustomDebugStringConvertible {
    /// The URL request sent to the server.
    public let request: URLRequest?
    
    /// The server's response to the URL request.
    public let response: HTTPURLResponse?
    
    /// The data returned by the server.
    public let data: Data?
    
    /// The error encountered while executing or validating the request.
    public let error: Error?
    
    internal init(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?)
    {
        self.request = request
        self.response = response
        self.data = data
        self.error = error
    }
    
    internal init(from alamofire: Alamofire.DefaultDataResponse) {
        self.request = alamofire.request
        self.response = alamofire.response
        self.data = alamofire.data
        self.error = alamofire.error
    }
    
    public var description: String {
        return debugDescription
    }
    
    public var debugDescription: String {
        var ouput = [String]()
        ouput.append("{")
        ouput.append("\trequest: \(request)")
        ouput.append("\tresponse: \(response)")
        ouput.append("\tdata: \(data)")
        ouput.append("\terror: \(error?.localizedDescription)")
        ouput.append("}")
        return ouput.joined(separator: "\n")
    }
}


// MARK: -

/// Used to store all data associated with a serialized response of a data or upload request.
public struct DataResponse<Value>: CustomStringConvertible, CustomDebugStringConvertible {
    /// The URL request sent to the server.
    public let request: URLRequest?
    
    /// The server's response to the URL request.
    public let response: HTTPURLResponse?
    
    /// The data returned by the server.
    public let data: Data?
    
    /// The result of response serialization.
    public let result: Result<Value>
    
    internal init(
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
    
    internal init(from alamofire: Alamofire.DataResponse<Value>) {
        self.request = alamofire.request
        self.response = alamofire.response
        self.data = alamofire.data
        if alamofire.result.isSuccess {
            self.result = Result<Value>.success(alamofire.result.value!)
        } else {
            self.result = Result<Value>.failure(RedesError.internalFailed(reason: alamofire.result.error!))
        }
    }
    
    public var description: String {
        return debugDescription
    }
    
    public var debugDescription: String {
        var ouput = [String]()
        ouput.append("{")
        ouput.append("\trequest: \(request)")
        ouput.append("\tresponse: \(response)")
        ouput.append("\tdata: \(data?.count ?? 0) bytes")
        ouput.append("}")
        return ouput.joined(separator: "\n")
    }
}

private func dataResponse<T: Parsable>(from resp: Alamofire.DataResponse<Any>, using parser: T) -> DataResponse<T.Out> {
    var result: Result<T.Out>
    if resp.result.isSuccess {
        if let raw = resp.result.value {
            do {
                let parsed = try parser.parse(data: raw)
                result = Result<T.Out>.success(parsed)
            } catch RedesError.parseFailed(reason: let reason) {
                result = Result<T.Out>.failure(RedesError.parseFailed(reason: reason))
            } catch RedesError.businessFailed(reason: let reason) {
                result = Result<T.Out>.failure(RedesError.businessFailed(reason: reason))
            } catch {
                fatalError("should not throw this kind error.")
            }
        } else {
            result = Result<T.Out>.failure(RedesError.parseFailed(reason: .formInvalid))
        }
    } else {
        result = Result<T.Out>.failure(RedesError.internalFailed(reason: resp.result.error!))
    }
    
    let dataResponse = DataResponse(
        request: resp.request,
        response: resp.response,
        data: resp.data,
        result: result
    )
    
    return dataResponse
}


// MARK: - 

/// Used to store all data associated with an non-serialized response of a download request.
public struct DefaultDownloadResponse {
    /// The URL request sent to the server.
    public let request: URLRequest?
    
    /// The server's response to the URL request.
    public let response: HTTPURLResponse?
    
    /// The temporary destination URL of the data returned from the server.
    public let temporaryURL: URL?
    
    /// The final destination URL of the data returned from the server if it was moved.
    public let destinationURL: URL?
    
    /// The resume data generated if the request was cancelled.
    public let resumeData: Data?
    
    /// The error encountered while executing or validating the request.
    public let error: Error?

    init(
        request: URLRequest?,
        response: HTTPURLResponse?,
        temporaryURL: URL?,
        destinationURL: URL?,
        resumeData: Data?,
        error: Error?)
    {
        self.request = request
        self.response = response
        self.temporaryURL = temporaryURL
        self.destinationURL = destinationURL
        self.resumeData = resumeData
        self.error = error
    }
    
    internal init(from alamofire: Alamofire.DefaultDownloadResponse) {
        self.request = alamofire.request
        self.response = alamofire.response
        self.temporaryURL = alamofire.temporaryURL
        self.destinationURL = alamofire.destinationURL
        self.resumeData = alamofire.resumeData
        self.error = alamofire.error
    }
}

// MARK: -

/// Used to store all data associated with a serialized response of a download request.
public struct DownloadResponse<Value>: CustomStringConvertible, CustomDebugStringConvertible {
    /// The URL request sent to the server.
    public let request: URLRequest?
    
    /// The server's response to the URL request.
    public let response: HTTPURLResponse?
    
    /// The temporary destination URL of the data returned from the server.
    public let temporaryURL: URL?
    
    /// The final destination URL of the data returned from the server if it was moved.
    public let destinationURL: URL?
    
    /// The resume data generated if the request was cancelled.
    public let resumeData: Data?
    
    /// The result of response serialization.
    public let result: Result<Value>
    
    init(
        request: URLRequest?,
        response: HTTPURLResponse?,
        temporaryURL: URL?,
        destinationURL: URL?,
        resumeData: Data?,
        result: Result<Value>)
    {
        self.request = request
        self.response = response
        self.temporaryURL = temporaryURL
        self.destinationURL = destinationURL
        self.resumeData = resumeData
        self.result = result
    }
    
    internal init(from alamofire: Alamofire.DownloadResponse<Value>) {
        self.request = alamofire.request
        self.response = alamofire.response
        self.temporaryURL = alamofire.temporaryURL
        self.destinationURL = alamofire.destinationURL
        self.resumeData = alamofire.resumeData
        if alamofire.result.isSuccess {
            self.result = Result<Value>.success(alamofire.result.value!)
        } else {
            self.result = Result<Value>.failure(RedesError.internalFailed(reason: alamofire.result.error!))
        }
    }
    
    public var description: String {
        return debugDescription
    }
    
    public var debugDescription: String {
        var ouput = [String]()
        ouput.append("{")
        ouput.append("\trequest: \(request)")
        ouput.append("\tresponse: \(response)")
        ouput.append("\ttemporaryURL: \(temporaryURL)")
        ouput.append("\tdestinationURL: \(destinationURL)")
        ouput.append("\tresumeData: \(resumeData?.count ?? 0) bytes")
        ouput.append("}")
        return ouput.joined(separator: "\n")
    }
}

private func downloadResponse<T: Parsable>(from resp: Alamofire.DownloadResponse<Any>, using parser: T) -> DownloadResponse<T.Out> {
    var result: Result<T.Out>
    if resp.result.isSuccess {
        if let raw = resp.result.value {
            do {
                let parsed = try parser.parse(data: raw)
                result = Result<T.Out>.success(parsed)
            } catch RedesError.parseFailed(reason: let reason) {
                result = Result<T.Out>.failure(RedesError.parseFailed(reason: reason))
            } catch RedesError.businessFailed(reason: let reason) {
                result = Result<T.Out>.failure(RedesError.businessFailed(reason: reason))
            } catch {
                fatalError("should not throw this kind error.")
            }
        } else {
            result = Result<T.Out>.failure(RedesError.parseFailed(reason: .formInvalid))
        }
    } else {
        result = Result<T.Out>.failure(RedesError.internalFailed(reason: resp.result.error!))
    }
    
    let downloadResponse = DownloadResponse(
        request: resp.request,
        response: resp.response,
        temporaryURL: resp.temporaryURL,
        destinationURL: resp.destinationURL,
        resumeData: resp.resumeData,
        result: result
    )
    
    return downloadResponse
}

// MARK: - 

public protocol Parsable {
    associatedtype Out
    func parse(data: Any) throws -> Out
}

/// Server response [json][xml][plist][...] should like this format,
/// you can define those field by youself.
///    {
///        "code": 0,
///        "msg": "",
///        "data": {}
///    }
public struct DefaultParser<Output>: Parsable {
    public let codeFieldName: String
    public let messageFieldName: String
    public let dataFieldName: String

    /// My situation is: ["codeFieldName": "code", "messageFieldName": "msg", "data": "result"]
    public init(codeFieldName: String = "code", messageFieldName: String = "msg", dataFieldName: String = "result") {
        self.codeFieldName = codeFieldName
        self.messageFieldName = messageFieldName
        self.dataFieldName = dataFieldName
    }
    
    public typealias Out = Output

    public func parse(data: Any) throws -> Out {
        func intValue(fromJson json: [String: Any], forField key: String) -> Int? {
            if let value = json[key] as? String {
                return Int(value)
            } else if let value = json[key] as? Int {
                return value
            }
            return nil
        }
        
        guard let json = data as? [String: Any] else {
            throw RedesError.parseFailed(reason: RedesError.ParseFailureReason.formInvalid)
        }
        
        guard let code =  intValue(fromJson: json, forField: codeFieldName) else {
            throw RedesError.parseFailed(reason: RedesError.ParseFailureReason.codeCanNotFound)
        }
        
        if 0 != code {
            // failure
            guard let message = json[messageFieldName] as? String else {
                throw RedesError.parseFailed(reason: RedesError.ParseFailureReason.messageCanNotFound)
            }
            throw RedesError.businessFailed(reason: RedesError.BusinessFailedReason(code: code, message: message))
        } else {
            // success
            guard let data = json[dataFieldName] as? Output else {
                throw RedesError.parseFailed(reason: RedesError.ParseFailureReason.dataCanNotFound)
            }
            return data
        }
    }
}

// MARK: -  DataRequest

public extension DataRequest {
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func response(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DefaultDataResponse) -> ()) -> DataRequest
    {
        underlying.response(queue: queue) { (resp: Alamofire.DefaultDataResponse) in
            completionHandler(DefaultDataResponse(from: resp))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseData(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Data>) -> ()) -> DataRequest
    {
        underlying.responseData(queue: queue) { (resp: Alamofire.DataResponse<Data>) in
            completionHandler(DataResponse(from: resp))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseString(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<String>) -> ()) -> DataRequest
    {
        underlying.responseString(queue: queue) { (resp: Alamofire.DataResponse<String>) in
            completionHandler(DataResponse(from: resp))
        }
        
        return self
    }

    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter parser:            The parser to process vendors framework response data.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseJSON<T: Parsable>(
        queue: DispatchQueue? = nil,
        parser: T,
        completionHandler: @escaping (DataResponse<T.Out>) -> ()) -> DataRequest
    {
        underlying.responseJSON(queue: queue) { (resp: Alamofire.DataResponse<Any>) in
            completionHandler(dataResponse(from: resp, using: parser))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Any>) -> ()) -> DataRequest
    {
        return responseJSON(queue: queue, parser: DefaultParser<Any>(), completionHandler: completionHandler)
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responsePropertyList<T: Parsable>(
        queue: DispatchQueue? = nil,
        parser: T,
        completionHandler: @escaping (DataResponse<T.Out>) -> ()) -> DataRequest
    {
        underlying.responsePropertyList(queue: queue) { (resp: Alamofire.DataResponse<Any>) in
            completionHandler(dataResponse(from: resp, using: parser))
        }

        return self
    }
}

// MARK: - BatchRequest

public extension BatchRequest {
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func response(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping ([DefaultDataResponse]) -> ()) -> BatchRequest
    {
        let group = DispatchGroup()
        let serialQueue = DispatchQueue(label: "com.mochxiao.redes.batchrequst.response."
            + UUID().uuidString.replacingOccurrences(of: "-", with: ""))
        var results: [DefaultDataResponse] = []

        underlyings.forEach { (request: Alamofire.DataRequest) in
            serialQueue.async(group: group, flags: .barrier) {
                let semaphore = DispatchSemaphore(value: 0)
                request.response(queue: DispatchQueue.global()) { (resp: Alamofire.DefaultDataResponse) in
                    results.append(DefaultDataResponse(from: resp))
                    semaphore.signal()
                }
                semaphore.wait()
            }
        }
        
        group.notify(queue: serialQueue) {
            (queue ?? DispatchQueue.main).async {
                completionHandler(results)
            }
        }
        
        return self
    }

    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseData(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping ([DataResponse<Data>]) -> ()) -> BatchRequest
    {
        let group = DispatchGroup()
        let serialQueue = DispatchQueue(label: "com.mochxiao.redes.batchrequst.responsedata."
            + UUID().uuidString.replacingOccurrences(of: "-", with: ""))
        var results: [DataResponse<Data>] = []

        underlyings.forEach { (request: Alamofire.DataRequest) in
            serialQueue.async(group: group, flags: .barrier) {
                let semaphore = DispatchSemaphore(value: 0)
                request.responseData(queue: DispatchQueue.global()) { (resp: Alamofire.DataResponse<Data>) in
                    results.append(DataResponse<Data>(from: resp))
                    semaphore.signal()
                }
                semaphore.wait()
            }
        }
        
        group.notify(queue: serialQueue) {
            (queue ?? DispatchQueue.main).async {
                completionHandler(results)
            }
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseString(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping ([DataResponse<String>]) -> ()) -> BatchRequest
    {
        let group = DispatchGroup()
        let serialQueue = DispatchQueue(label: "com.mochxiao.redes.batchrequst.responsedata."
            + UUID().uuidString.replacingOccurrences(of: "-", with: ""))
        var results: [DataResponse<String>] = []
        
        underlyings.forEach { (request: Alamofire.DataRequest) in
            serialQueue.async(group: group, flags: .barrier) {
                let semaphore = DispatchSemaphore(value: 0)
                request.responseString(queue: DispatchQueue.global()) { (resp: Alamofire.DataResponse<String>) in
                    results.append(DataResponse<String>(from: resp))
                    semaphore.signal()
                }
                semaphore.wait()
            }
        }
        
        group.notify(queue: serialQueue) {
            (queue ?? DispatchQueue.main).async {
                completionHandler(results)
            }
        }
        
        return self
    }
    

    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter parser:            The parser to process vendors framework response data.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseJSON<T: Parsable>(
        queue: DispatchQueue? = nil,
        parser: T,
        completionHandler: @escaping ([DataResponse<T.Out>]) -> ()) -> BatchRequest
    {
        let group = DispatchGroup()
        let serialQueue = DispatchQueue(label: "com.mochxiao.redes.batchrequst.responsejson."
            + UUID().uuidString.replacingOccurrences(of: "-", with: ""))
        var results: [DataResponse<T.Out>] = []

        underlyings.forEach { (request: Alamofire.DataRequest) in
            serialQueue.async(group: group, flags: .barrier) {
                let semaphore = DispatchSemaphore(value: 0)
                request.responseJSON(queue: DispatchQueue.global()) { (resp: Alamofire.DataResponse<Any>) in
                    results.append(dataResponse(from: resp, using: parser))
                    semaphore.signal()
                }
                semaphore.wait()
            }
        }
        
        group.notify(queue: serialQueue) {
            (queue ?? DispatchQueue.main).async {
                completionHandler(results)
            }
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping ([DataResponse<Any>]) -> ()) -> BatchRequest
    {
        return responseJSON(queue: queue, parser: DefaultParser<Any>(), completionHandler: completionHandler)
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responsePropertyList<T: Parsable>(
        queue: DispatchQueue? = nil,
        parser: T,
        completionHandler: @escaping ([DataResponse<T.Out>]) -> ()) -> BatchRequest
    {
        let group = DispatchGroup()
        let serialQueue = DispatchQueue(label: "com.mochxiao.redes.batchrequst.responsepropertylist."
            + UUID().uuidString.replacingOccurrences(of: "-", with: ""))
        var results: [DataResponse<T.Out>] = []
        
        underlyings.forEach { (request: Alamofire.DataRequest) in
            serialQueue.async(group: group, flags: .barrier) {
                let semaphore = DispatchSemaphore(value: 0)
                request.responsePropertyList(queue: DispatchQueue.global()) { (resp: Alamofire.DataResponse<Any>) in
                    results.append(dataResponse(from: resp, using: parser))
                    semaphore.signal()
                }
                semaphore.wait()
            }
        }
        
        group.notify(queue: serialQueue) {
            (queue ?? DispatchQueue.main).async {
                completionHandler(results)
            }
        }
        
        return self
    }
}

// MARK: - UploadRequest

public extension UploadRequest {
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func response(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DefaultDataResponse) -> ()) -> UploadRequest
    {
        underlying.response(queue: queue) { (resp: Alamofire.DefaultDataResponse) in
            completionHandler(DefaultDataResponse(from: resp))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseData(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Data>) -> ()) -> UploadRequest
    {
        underlying.responseData(queue: queue) { (resp: Alamofire.DataResponse<Data>) in
            completionHandler(DataResponse(from: resp))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseString(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<String>) -> ()) -> UploadRequest
    {
        underlying.responseString(queue: queue) { (resp: Alamofire.DataResponse<String>) in
            completionHandler(DataResponse(from: resp))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter parser:            The parser to process vendors framework response data.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseJSON<T: Parsable>(
        queue: DispatchQueue? = nil,
        parser: T,
        completionHandler: @escaping (DataResponse<T.Out>) -> ()) -> UploadRequest
    {
        underlying.responseJSON(queue: queue) { (resp: Alamofire.DataResponse<Any>) in
            completionHandler(dataResponse(from: resp, using: parser))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Any>) -> ()) -> UploadRequest
    {
        return responseJSON(queue: queue, parser: DefaultParser<Any>(), completionHandler: completionHandler)
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responsePropertyList<T: Parsable>(
        queue: DispatchQueue? = nil,
        parser: T,
        completionHandler: @escaping (DataResponse<T.Out>) -> ()) -> UploadRequest
    {
        underlying.responsePropertyList(queue: queue) { (resp: Alamofire.DataResponse<Any>) in
            completionHandler(dataResponse(from: resp, using: parser))
        }
        
        return self
    }
    
}

// MARK: - MultipartUploadRequest

public extension MultipartUploadRequest {
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    ///
    /// - returns: The request.
    public func response(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DefaultDataResponse) -> ()) -> MultipartUploadRequest
    {
        guard let result = result else {
            return self
        }
        
        switch result {
        case .success(let uploadRequest):
            uploadRequest.response(queue: queue) { (resp: Alamofire.DefaultDataResponse) in
                completionHandler(DefaultDataResponse(from: resp))
            }
        case .failure(let error):
            completionHandler(DefaultDataResponse(request: nil, response: nil, data: nil, error: error))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseData(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Data>) -> ()) -> MultipartUploadRequest
    {
        guard let result = result else {
            return self
        }
        
        switch result {
        case .success(let uploadRequest):
            uploadRequest.responseData(queue: queue) { (resp: Alamofire.DataResponse<Data>) in
                completionHandler(DataResponse<Data>(from: resp))
            }
        case .failure(let error):
            completionHandler(DataResponse(request: nil, response: nil, data: nil, result: Redes.Result.failure(.internalFailed(reason: error))))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseString(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<String>) -> ()) -> MultipartUploadRequest
    {
        guard let result = result else {
            return self
        }
        
        switch result {
        case .success(let uploadRequest):
            uploadRequest.responseString(queue: queue) { (resp: Alamofire.DataResponse<String>) in
                completionHandler(DataResponse<String>(from: resp))
            }
        case .failure(let error):
            completionHandler(DataResponse(request: nil, response: nil, data: nil, result: Redes.Result.failure(.internalFailed(reason: error))))
        }
        
        return self
    }

    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter parser:            The parser to process vendors framework response data.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseJSON<T: Parsable>(
        queue: DispatchQueue? = nil,
        parser: T,
        completionHandler: @escaping (DataResponse<T.Out>) -> ()) -> MultipartUploadRequest
    {
        guard let result = result else {
            return self
        }
        
        switch result {
        case .success(let uploadRequest):
            uploadRequest.responseJSON(queue: queue) { (resp: Alamofire.DataResponse<Any>) in
                completionHandler(dataResponse(from: resp, using: parser))
            }
        case .failure(let error):
            completionHandler(DataResponse(request: nil, response: nil, data: nil, result: Redes.Result.failure(.internalFailed(reason: error))))
        }

        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Any>) -> ()) -> MultipartUploadRequest
    {
        return responseJSON(queue: queue, parser: DefaultParser<Any>(), completionHandler: completionHandler)
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responsePropertyList<T: Parsable>(
        queue: DispatchQueue? = nil,
        parser: T,
        completionHandler: @escaping (DataResponse<T.Out>) -> ()) -> MultipartUploadRequest
    {
        guard let result = result else {
            return self
        }
        
        switch result {
        case .success(let uploadRequest):
            uploadRequest.responsePropertyList(queue: queue) { (resp: Alamofire.DataResponse<Any>) in
                completionHandler(dataResponse(from: resp, using: parser))
            }
        case .failure(let error):
            completionHandler(DataResponse(request: nil, response: nil, data: nil, result: Redes.Result.failure(.internalFailed(reason: error))))
        }
        
        return self
    }
}


// MARK: - DownloadRequest

public extension DownloadRequest {
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func response(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DefaultDownloadResponse) -> ()) -> DownloadRequest
    {
        underlying.response(queue: queue) { (resp: Alamofire.DefaultDownloadResponse) in
            completionHandler(DefaultDownloadResponse(from: resp))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseData(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DownloadResponse<Data>) -> ()) -> DownloadRequest
    {
        underlying.responseData(queue: queue) { (resp: Alamofire.DownloadResponse<Data>) in
            completionHandler(DownloadResponse(from: resp))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseString(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DownloadResponse<String>) -> ()) -> DownloadRequest
    {
        underlying.responseString(queue: queue) { (resp: Alamofire.DownloadResponse<String>) in
            completionHandler(DownloadResponse(from: resp))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter parser:            The parser to process vendors framework response data.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseJSON<T: Parsable>(
        queue: DispatchQueue? = nil,
        parser: T,
        completionHandler: @escaping (DownloadResponse<T.Out>) -> ()) -> DownloadRequest
    {
        underlying.responseJSON(queue: queue) { (resp: Alamofire.DownloadResponse<Any>) in
            completionHandler(downloadResponse(from: resp, using: parser))
        }
        
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DownloadResponse<Any>) -> ()) -> DownloadRequest
    {
        return responseJSON(queue: queue, parser: DefaultParser<Any>(), completionHandler: completionHandler)
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responsePropertyList<T: Parsable>(
        queue: DispatchQueue? = nil,
        parser: T,
        completionHandler: @escaping (DownloadResponse<T.Out>) -> ()) -> DownloadRequest
    {
        underlying.responsePropertyList(queue: queue) { (resp: Alamofire.DownloadResponse<Any>) in
            completionHandler(downloadResponse(from: resp, using: parser))
        }
        
        return self
    }
}
