//
//  AlamofireCommand.swift
//  Redes
//
//  Created by Moch Xiao on 11/9/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

final public class AlamofireCommand: Command {
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
        cacheRequest()
    }
    
    // Check network reachability
    private func isNetworkUnavailable() -> Bool {
        // Supporse default is available
        guard let sharedManager = ReachabilityManager.sharedManager else { return false }
        
        return !sharedManager.isReachable()
    }
    
    private func produceRequest() {
        guard let request = request else { return }

        if isNetworkUnavailable() {
            request.networkUnavailable = true
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
    
    private func cacheRequest() {
        guard let underlyingRequest = underlyingRequest else { return }
        
        underlyingRequest.delegate.queue.addOperationWithBlock { () -> Void in
            debugPrint("Request completion.")
        }
    }
    
    public func removeRequest() {
        guard let underlyingRequest = underlyingRequest else { return }
        
        let state = underlyingRequest.task.state
        if state == .Running || state == .Suspended {
            underlyingRequest.task.cancel()
            debugPrint("Canceling request...")
        }
    }
}

// MARK: - Response

public extension AlamofireCommand {
    func response(
        queue queue: dispatch_queue_t?,
        completionHandler: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> ())
    {
        guard let request = request else { return }
        
        if request.networkUnavailable {
            dispatch_async(queue ?? dispatch_get_main_queue(), {
                completionHandler(nil, nil, nil, nil)
            })
            return
        }
        
        underlyingRequest?.response(queue: queue, completionHandler: completionHandler)
    }
    
    func responseData(
        queue queue: dispatch_queue_t?,
        completionHandler: Result<Response, NSData, NSError> -> ())
    {
        guard let request = request else { return }
        
        if request.networkUnavailable {
            bridgeToNetworkUnavailable(
                setup: request.setup,
                completionHandler: completionHandler,
                queue: queue
            )
            return
        }
        
        underlyingRequest?.response(
            queue: queue,
            responseSerializer: Alamofire.Request.dataResponseSerializer(),
            completionHandler: {
                [unowned self] in
                self.bridgeToResult(
                    completionHandler: completionHandler,
                    validationHandler: request.setup.responseDataValidation,
                    response: $0
                )
        })
    }
    
    func responseString(
        queue queue: dispatch_queue_t?,
        encoding: NSStringEncoding?,
        completionHandler: Result<Response, String, NSError> -> ())
    {
        guard let request = request else { return }
        
        if request.networkUnavailable {
            bridgeToNetworkUnavailable(
                setup: request.setup,
                completionHandler: completionHandler,
                queue: queue
            )
            return
        }

        underlyingRequest?.response(
            queue: queue,
            responseSerializer: Alamofire.Request.stringResponseSerializer(encoding: encoding),
            completionHandler: {
                [unowned self] in
                self.bridgeToResult(
                    completionHandler: completionHandler,
                    validationHandler: request.setup.responseStringValidation,
                    response: $0
                )
            }
        )
    }
    
    public func responseJSON(
        queue queue: dispatch_queue_t?,
        options: NSJSONReadingOptions,
        completionHandler: Result<Response, AnyObject, NSError> -> ())
    {
        guard let request = request else { return }
        
        if request.networkUnavailable {
            bridgeToNetworkUnavailable(
                setup: request.setup,
                completionHandler: completionHandler,
                queue: queue
            )
            return
        }
        
        underlyingRequest?.response(
            queue: queue,
            responseSerializer: Alamofire.Request.JSONResponseSerializer(options: options),
            completionHandler: {
                [unowned self] in
                self.bridgeToResult(
                    completionHandler: completionHandler,
                    validationHandler: request.setup.responseJSONValidation,
                    response: $0
                )
            }
        )
    }
    
    func responsePropertyList(
        queue queue: dispatch_queue_t?,
        options: NSPropertyListReadOptions,
        completionHandler: Result<Response, AnyObject, NSError> -> ())
    {
        guard let request = request else { return }
        
        if request.networkUnavailable {
            bridgeToNetworkUnavailable(
                setup: request.setup,
                completionHandler: completionHandler,
                queue: queue
            )
            return
        }

        underlyingRequest?.response(
            queue: queue,
            responseSerializer: Alamofire.Request.propertyListResponseSerializer(options: options),
            completionHandler: {
                [unowned self] in
                self.bridgeToResult(
                    completionHandler: completionHandler,
                    validationHandler: request.setup.responsePropertyListValidation,
                    response: $0
                )
            }
        )
    }
}

// MARK: - Helper

public extension AlamofireCommand {
    /// Generate manual failure closure parameters
    func buildFailureResult<T>(
        response response: Alamofire.Response<T, NSError>,
        message: String = "Server response illegal.",
        statusCode: Int = RequestFailureStatusCode)
        -> Result<Response, T, NSError>
    {
        let rsp = Response(
            setup: request!.setup,
            data: response.data,
            message: message,
            statusCode: statusCode
        )
        let error = Error.errorWithCode(statusCode, failureReason: message)
        return .Failure(rsp, error)
    }
    
    /// Generate server request failure closure parameters
    func requestFailureResult<T>(response response: Alamofire.Response<T, NSError>)
        -> Result<Response, T, NSError>
    {
        let codeValue = response.response?.statusCode ?? RequestFailureStatusCode;

        return buildFailureResult(
            response: response,
            message: "Request failed.",
            statusCode: codeValue
        )
    }
    
    /// Generate success closure parameters
    func buildSuccessResult<T>(
        response response: Alamofire.Response<T, NSError>,
        result: T,
        message: String,
        statusCode: Int)
        -> Result<Response, T, NSError>
    {
        let rsp = Response(
            setup: request!.setup,
            data: response.data,
            message: message,
            statusCode: statusCode
        )
        return .Success(rsp, result)
    }
    
    /// Birdege `Alamofire` response to `Redes` result
    func bridgeToResult<K>(
        completionHandler completionHandler: Result<Response, K, NSError> -> (),
        validationHandler: K -> (Bool, K, String, Int),
        response: Alamofire.Response<K, NSError>)
    {
        if response.result.isSuccess {
            // pretty value
            guard let pretty = response.result.value else {
                // Server did not return data
                return completionHandler(buildFailureResult(response: response))
            }
            // Print pertty value
            debugPrint(pretty)
            
            let (success, result, message, statusCode) = validationHandler(pretty)
            if success {
                completionHandler(buildSuccessResult(
                    response: response,
                    result: result,
                    message: message,
                    statusCode: statusCode)
                )
            } else {
                completionHandler(buildFailureResult(response: response))
            }
        } else {
            completionHandler(buildFailureResult(response: response))
        }
    }
    
    func bridgeToNetworkUnavailable<T>(
        setup setup: protocol<Requestable, Responseable>,
        completionHandler: Result<Response, T, NSError> -> (),
        queue: dispatch_queue_t?)
    {
        dispatch_async(queue ?? dispatch_get_main_queue(), {
            let message = "Network unavailable."
            let error = Error.errorWithCode(NetworkUnavailableStatusCode, failureReason: message)
            let rsp = Response(
                setup: setup,
                data: nil,
                message: message,
                statusCode: NetworkUnavailableStatusCode
            )
            completionHandler(.Failure(rsp, error))
        })
    }
}
