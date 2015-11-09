//
//  AlamofireCommand.swift
//  Redes
//
//  Created by Moch Xiao on 11/9/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

public class AlamofireCommand: Command {
    public private(set) weak var request: Request?
    private var underlyingRequest: Alamofire.Request?
    
    deinit {
        debugPrint("AlamofireCommand deinit...")
    }
}

// MARK: - Request

public extension AlamofireCommand {
    public func injectRequest(request: Request) {
        self.request = request
        
        produceRequest()
    }
    
    private func produceRequest() {
        guard let request = request else {
            return
        }
        
        Alamofire.Manager.sharedInstance.session.configuration.timeoutIntervalForRequest = request.setup.requestTimeoutInterval
        
        let method = request.setup.requestMethod.method()
        let requestURLPath = request.setup.requestURLPath
        let requestHeaderParameters = request.setup.requestHeaderParameters
        
        if let uploadCommand = request.setup as? Uploadable {
            // Need download
            if !uploadCommand.validateUpload {
                fatalError("You must implement one of protocol `Uploadable` `uploadXXX` methods.")
            }
            
            if let uploadFileURL = uploadCommand.uploadFileURL {
                underlyingRequest = Alamofire.upload(
                    method,
                    requestURLPath,
                    headers: requestHeaderParameters,
                    file: uploadFileURL
                )
            } else if let data = uploadCommand.uploadData {
                underlyingRequest = Alamofire.upload(
                    method,
                    requestURLPath,
                    headers: requestHeaderParameters,
                    data: data
                )
            } else if let stream = uploadCommand.uploadStream {
                underlyingRequest = Alamofire.upload(
                    method,
                    requestURLPath,
                    headers: requestHeaderParameters,
                    stream: stream
                )
            } else if let (dataClosure, encodingResultClosure, threshold) = uploadCommand.uploadMultipartFormDataTuple {
                Alamofire.upload(
                    method,
                    requestURLPath,
                    headers: requestHeaderParameters,
                    multipartFormData: dataClosure,
                    encodingMemoryThreshold: threshold,
                    encodingCompletion: encodingResultClosure
                )
            }
        } else if let downloadCommand = request.setup as? Downloadable {
            // Need upload
            let (resumeData, downloadFileDestination) = downloadCommand.downloadDestinationTuple
            if let resumeData = resumeData {
                underlyingRequest = Alamofire.download(resumeData: resumeData, destination: downloadFileDestination)
            } else {
                underlyingRequest = Alamofire.download(
                    method,
                    requestURLPath,
                    parameters: request.setup.requestBodyParameters,
                    encoding: request.setup.requestParameterEncoding.parameterEncoding(),
                    headers: requestHeaderParameters,
                    destination: downloadFileDestination
                )
            }
        } else {
            // Use Alamofire start networking request
            underlyingRequest = Alamofire.request(
                method,
                requestURLPath,
                parameters: request.setup.requestBodyParameters,
                encoding: request.setup.requestParameterEncoding.parameterEncoding(),
                headers: requestHeaderParameters
            )
        }
    }
    
    public func removeRequest() {
        guard let underlyingRequest = underlyingRequest else {
            return
        }
        
        let state = underlyingRequest.task.state
        if state == .Running || state == .Suspended {
            underlyingRequest.task.cancel()
            debugPrint("Canceling request...")
        }
    }
}

// MARK: - Response

public extension AlamofireCommand {
    func responseData(completionHandler: Result<Response, NSData, NSError> -> Void)
    {
        guard let request = request else {
            return
        }
        
        // Trailing closure
        underlyingRequest?.responseData() { [unowned self] in
            self.bridgeToResultCompletionHandler(
                completionHandler,
                validationHandler: request.setup.responseDataValidation,
                response: $0
            )
        }
    }
    
    func responseString(
        encoding encoding: NSStringEncoding?,
        completionHandler: Result<Response, String, NSError>-> Void)
    {
        guard let request = request else {
            return
        }
        
        underlyingRequest?.responseString(encoding: encoding, completionHandler: { [unowned self] in
            self.bridgeToResultCompletionHandler(
                completionHandler,
                validationHandler: request.setup.responseStringValidation,
                response: $0
            )
        })
    }
    
    public func responseJSON(
        options options: NSJSONReadingOptions,
        completionHandler: Result<Response, AnyObject, NSError> -> Void)
    {
        guard let request = request else {
            return
        }
        
        underlyingRequest?.responseJSON(options: options, completionHandler: { [unowned self] in
            self.bridgeToResultCompletionHandler(
                completionHandler,
                validationHandler: request.setup.responseJSONValidation,
                response: $0
            )
        })
    }
    
    func responsePropertyList(
        options options: NSPropertyListReadOptions,
        completionHandler: Result<Response, AnyObject, NSError> -> Void)
    {
        guard let request = request else {
            return
        }
        
        underlyingRequest?.responsePropertyList(options: options, completionHandler: { [unowned self] in
            self.bridgeToResultCompletionHandler(
                completionHandler,
                validationHandler: request.setup.responsePropertyListValidation,
                response: $0
            )
        })
    }
}

// MARK: - Helper

public extension AlamofireCommand {
    /// Generate manual failure closure parameters
    func buildFailureResultByResponse<T>(
        response: Alamofire.Response<T, NSError>,
        message: String = "Server response llegal",
        statusCode: Int = RequestFailureStatusCode
    ) -> Result<Response, T, NSError>
    {
        let rsp = Response(
            setup: self.request!.setup,
            data: response.data,
            message: message,
            statusCode: statusCode
        )
        let error = Error.errorWithCode(statusCode, failureReason: message)
        return .Failure(rsp, error)
    }
    
    /// Generate server request failure closure parameters
    func requestFailureResultByResponse<T>(response: Alamofire.Response<T, NSError>)
        -> Result<Response, T, NSError>
    {
        let codeValue = response.response?.statusCode ?? RequestFailureStatusCode;
        return buildFailureResultByResponse(
            response,
            message: "Request failed.",
            statusCode:
            codeValue
        )
    }
    
    /// Generate success closure parameters
    func buildSuccessResultByResponse<T>(
        response: Alamofire.Response<T, NSError>,
        result: T,
        message: String,
        statusCode: Int
    ) -> Result<Response, T, NSError>
    {
        let rsp = Response(
            setup: self.request!.setup,
            data: response.data,
            message: message,
            statusCode: statusCode
        )
        return .Success(rsp, result)
    }
    
    /// Birdege `Alamofire` response to `Redes` result
    func bridgeToResultCompletionHandler<K>(
        completionHandler: Result<Response, K, NSError> -> Void,
        validationHandler: K -> (Bool, K, String, Int),
            response: Alamofire.Response<K, NSError>)
    {
        if response.result.isSuccess {
            // pretty value
            guard let pretty = response.result.value else {
                // Server did not return data
                return completionHandler(self.buildFailureResultByResponse(response))
            }
            // Print pertty value
            debugPrint(pretty)
            
            let (success, result, message, statusCode) = validationHandler(pretty)
            if success {
                completionHandler(self.buildSuccessResultByResponse(
                    response,
                    result: result,
                    message: message,
                    statusCode: statusCode)
                )
            } else {
                completionHandler(self.buildFailureResultByResponse(response))
            }
        } else {
            completionHandler(self.requestFailureResultByResponse(response))
        }
    }
}
