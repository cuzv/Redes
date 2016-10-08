//
//  Response.swift
//  Redes
//
//  Created by Moch Xiao on 10/6/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

// MARK: -

public struct DefaultDataResponse: CustomStringConvertible, CustomDebugStringConvertible {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
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

public struct DataResponse<Value>: CustomStringConvertible, CustomDebugStringConvertible {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
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

public struct DefaultDownloadResponse {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let temporaryURL: URL?
    public let destinationURL: URL?
    public let resumeData: Data?
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
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let temporaryURL: URL?
    public let destinationURL: URL?
    public let resumeData: Data?
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


public struct DefaultParser<Output>: Parsable {
    public let codeFieldName: String
    public let messageFieldName: String
    public let dataFieldName: String

    /// Server response [json][xml][plist][...] should like this format,
    /// you can define those field by youself.
    ///    {
    ///        "code": 0,
    ///        "msg": "",
    ///        "data": {}
    ///    }
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
    
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Any>) -> ()) -> DataRequest
    {
        return responseJSON(queue: queue, parser: DefaultParser<Any>(), completionHandler: completionHandler)
    }
    
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
    
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping ([DataResponse<Any>]) -> ()) -> BatchRequest
    {
        return responseJSON(queue: queue, parser: DefaultParser<Any>(), completionHandler: completionHandler)
    }
    
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
    
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Any>) -> ()) -> UploadRequest
    {
        return responseJSON(queue: queue, parser: DefaultParser<Any>(), completionHandler: completionHandler)
    }
    
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
    
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Any>) -> ()) -> MultipartUploadRequest
    {
        return responseJSON(queue: queue, parser: DefaultParser<Any>(), completionHandler: completionHandler)
    }
}


// MARK: - DownloadRequest

public extension DownloadRequest {
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
    
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DownloadResponse<Any>) -> ()) -> DownloadRequest
    {
        return responseJSON(queue: queue, parser: DefaultParser<Any>(), completionHandler: completionHandler)
    }
    
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
