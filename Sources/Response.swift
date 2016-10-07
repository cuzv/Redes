//
//  Response.swift
//  Redes
//
//  Created by Moch Xiao on 10/6/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

/// Server response [json][xml][plist][...] should like this format,
/// you can define those field by youself.
///    {
///        "code": 0,
///        "msg": "",
///        "data": {}
///    }
public enum Fields {
    static var code     = "code"
    static var message  = "msg"
    static var data     = "result"
}

public protocol Parsable {
    associatedtype In
    associatedtype Out
    func parse(data: In) throws -> Out
}

public struct DefaultParser<Input, Output>: Parsable {
    public init() {}
    
    public typealias In = Input
    public typealias Out = Output

    public func parse(data: Input) throws -> Output {
        guard let rsp = data as? [String: Any] else {
            throw RedesError.parseFailed(reason: RedesError.ParseFailureReason.formInvalid)
        }
        
        guard let code = rsp[Fields.code] as? Int else {
            throw RedesError.parseFailed(reason: RedesError.ParseFailureReason.codeCanNotFound)
        }
        
        if 0 != code {
            // failure
            guard let message = rsp[Fields.message] as? String else {
                throw RedesError.parseFailed(reason: RedesError.ParseFailureReason.messageCanNotFound)
            }
            throw RedesError.businessFailed(reason: RedesError.BusinessFailedReason(code: code, message: message))
        } else {
            // success
            guard let data = rsp[Fields.data] as? Output else {
                throw RedesError.parseFailed(reason: RedesError.ParseFailureReason.dataCanNotFound)
            }
            return data
        }
    }
}


// MARK: - 

public extension DataRequest {
    @discardableResult
    public func response(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DefaultDataResponse) -> Void) -> Self
    {
        guard let value = RedesRequestSender.shared.requestPairs[self] as? Alamofire.DataRequest else {
            fatalError("can not get request: \(self)")
        }
        
        value.response(queue: queue) { (resp: Alamofire.DefaultDataResponse) in
            completionHandler(DefaultDataResponse(
                request: resp.request,
                response: resp.response,
                data: resp.data,
                error: resp.error
            ))
        }
        
        return self
    }
    
    @discardableResult
    public func responseData(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Data>) -> Void) -> Self
    {
        guard let value = RedesRequestSender.shared.requestPairs[self] as? Alamofire.DataRequest else {
            fatalError("can not get request: \(self)")
        }

        value.responseData(queue: queue) { (resp: Alamofire.DataResponse<Data>) in
            let result: Result<Data>
            if resp.result.isSuccess {
                result = Result<Data>.success(resp.result.value!)
            } else {
                result = Result<Data>.failure(RedesError.internalFailed(reason: resp.result.error!))
            }
            let dataResponse = DataResponse(request: resp.request, response: resp.response, data: resp.data, result: result)
            completionHandler(dataResponse)
        }
        
        return self
    }
    
    @discardableResult
    public func responseString(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<String>) -> Void) -> Self
    {
        guard let value = RedesRequestSender.shared.requestPairs[self] as? Alamofire.DataRequest else {
            fatalError("can not get request: \(self)")
        }
        
        value.responseString(queue: queue) { (resp: Alamofire.DataResponse<String>) in
            let result: Result<String>
            if resp.result.isSuccess {
                result = Result<String>.success(resp.result.value!)
            } else {
                result = Result<String>.failure(RedesError.internalFailed(reason: resp.result.error!))
            }
            let dataResponse = DataResponse(request: resp.request, response: resp.response, data: resp.data, result: result)
            completionHandler(dataResponse)
        }
        
        return self
    }

    @discardableResult
    public func responseJSON<T: Parsable>(
        queue: DispatchQueue? = nil,
        parser: T,
        completionHandler: @escaping (DataResponse<T.Out>) -> Void) -> Self
    {
        guard let value = RedesRequestSender.shared.requestPairs[self] as? Alamofire.DataRequest else {
            fatalError("can not get request: \(self)")
        }
        
        value.responseJSON(queue: queue) { (resp: Alamofire.DataResponse<Any>) in
            completionHandler(self.dataResponse(from: resp, using: parser))
        }
        
        return self
    }
    
    @discardableResult
    public func responseJSON(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self
    {
        return responseJSON(queue: queue, parser: DefaultParser<[String: Any], Any>(), completionHandler: completionHandler)
    }
    
    @discardableResult
    public func responsePropertyList<T: Parsable>(
        queue: DispatchQueue? = nil,
        parser: T,
        completionHandler: @escaping (DataResponse<T.Out>) -> Void) -> Self
    {
        guard let value = RedesRequestSender.shared.requestPairs[self] as? Alamofire.DataRequest else {
            fatalError("can not get request: \(self)")
        }
        
        value.responsePropertyList(queue: queue) { (resp: Alamofire.DataResponse<Any>) in
            completionHandler(self.dataResponse(from: resp, using: parser))
        }

        return self
    }
    
    private func dataResponse<T: Parsable>(from resp: Alamofire.DataResponse<Any>, using parser: T) -> DataResponse<T.Out> {
        var result: Result<T.Out>
        if resp.result.isSuccess {
            if let raw = resp.result.value as? T.In {
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
}
