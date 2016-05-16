//
//  AlamofireCommand.swift
//  Redes
//
//  Created by Moch Xiao on 11/9/15.
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

final public class AlamofireCommand: Command {
    public private(set) weak var request: Request?
    private var underlyingRequest: Alamofire.Request?
    
    deinit {
        if RedesDebugModeEnabled {
            debugPrint("AlamofireCommand deinit...")
        }
    }
}

// MARK: - Request

public extension AlamofireCommand {
    public func injectRequest(request: Request) {
        self.request = request

        processRequest()
        doneRequest()
    }
    
    // Check network reachability
    private func isNetworkUnavailable() -> Bool {
        // Supporse default is available
        guard let sharedManager = ReachabilityManager.sharedManager else { return false }
        
        return !sharedManager.isReachable()
    }
    
    private func processRequest() {
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
            if !uploadCommand.isImplementedProtocolUploadable {
                fatalError("You must implement one of `uploadXXX` methods.")
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
            }
        } else if let multipartUploadCommand = request.setup as? MultipartUploadable {
            Alamofire.upload(
                method,
                requestURLPath,
                headers: requestHeaderParameters,
                multipartFormData: multipartUploadCommand.multipartFormData,
                encodingMemoryThreshold: multipartUploadCommand.encodingMemoryThreshold,
                encodingCompletion: { [weak self] (encodingResult: Manager.MultipartFormDataEncodingResult) in
                    guard let _self = self else { return }
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        _self.underlyingRequest = upload
                        multipartUploadCommand.completionHandler(request)
                        _self.doneRequest()
                    case .Failure(let encodingError):
                        let result: Alamofire.Result<Void, NSError> = .Failure(encodingError as NSError)
                        let response: Alamofire.Response<Void, NSError> = Alamofire.Response(request: nil, response: nil, data: nil, result: result)
                        _self.buildPhysicalFailureResult(response: response)
                    }
                }
            )
        } else if let downloadCommand = request.setup as? Downloadable {
            // Need download
            let destination = downloadCommand.destination
            if let resumeData = downloadCommand.resulmeData {
                underlyingRequest = Alamofire.download(resumeData: resumeData, destination: destination)
            } else {
                underlyingRequest = Alamofire.download(
                    method,
                    requestURLPath,
                    parameters: request.setup.requestBodyParameters,
                    encoding: request.setup.requestParameterEncoding.parameterEncoding(),
                    headers: requestHeaderParameters,
                    destination: destination
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
    
    private func doneRequest() {
        guard let underlyingRequest = underlyingRequest else { return }
        
        underlyingRequest.delegate.queue.addOperationWithBlock {
            if RedesDebugModeEnabled {
                debugPrint("Request completion.")
            }
        }
    }
    
    public func removeRequest() {
        guard let underlyingRequest = underlyingRequest else { return }
        
        let state = underlyingRequest.task.state
        if state == .Running || state == .Suspended {
            underlyingRequest.task.cancel()
            if RedesDebugModeEnabled {
                debugPrint("Removing request...")
            }
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
                let error = Error.redes_errorWithCode(RedesStatusCode.PhysicalError.rawValue, failureReason: "FAILURE: Network unavailable.")
                completionHandler(nil, nil, nil, error)
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
    
    func progress(closure: ((bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) -> Void)?) {
        underlyingRequest?.progress(closure)
    }
}

// MARK: - Helper

private extension AlamofireCommand {
    /// Generate manual failure closure parameters
    func buildOperationFailureResult<T>(
        response response: Alamofire.Response<T, NSError>,
        message: String,
        statusCode: Int)
        -> Result<Response, T, NSError>
    {
        let rsp = Response(
            setup: request!.setup,
            data: response.data,
            response: response.response,
            message: message,
            statusCode: statusCode
        )
        let error = Error.redes_errorWithCode(statusCode, failureReason: message)
        return .Failure(rsp, error)
    }
    
    /// Generate server request failure closure parameters
    func buildPhysicalFailureResult<T>(response response: Alamofire.Response<T, NSError>)
        -> Result<Response, T, NSError>
    {
        if RedesDebugModeEnabled {
            if let statusCode = response.response?.statusCode {
                debugPrint("Real status code: \(statusCode)")
            } else {
                debugPrint("Alamofire.Response: \(response)")
            }
        }
        
        return buildOperationFailureResult(
            response: response,
            message: "FAILURE: Server did not received request or client did not received response.",
            statusCode: RedesStatusCode.PhysicalError.rawValue
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
            response: response.response,
            message: message,
            statusCode: statusCode
        )
        return .Success(rsp, result)
    }
    
    /// Birdege `Alamofire` response to `Redes` result
    func bridgeToResult<K>(
        @noescape completionHandler completionHandler: Result<Response, K, NSError> -> (),
        @noescape validationHandler: K -> (Bool, K, String, Int),
        response: Alamofire.Response<K, NSError>)
    {
        if response.result.isSuccess {
            // pretty value
            guard let pretty = response.result.value else {
                // Server did not return data
                return completionHandler(buildOperationFailureResult(
                    response: response,
                    message: "FAILURE: Could not get response data.",
                    statusCode: RedesStatusCode.CouldNotGetResponseData.rawValue)
                )
            }
            
            if RedesDebugModeEnabled {
                // Print pertty value
                debugPrint("Pretty response print: \(pretty)")
            }
            
            let (success, result, message, statusCode) = validationHandler(pretty)
            if success {
                completionHandler(buildSuccessResult(
                    response: response,
                    result: result,
                    message: message,
                    statusCode: statusCode)
                )
            } else {
                completionHandler(buildOperationFailureResult(
                    response: response,
                    message: message,
                    statusCode: statusCode)
                )
            }
        } else {
            completionHandler(buildPhysicalFailureResult(response: response))
        }
    }
    
    func bridgeToNetworkUnavailable<T>(
        setup setup: protocol<Requestable, Responseable>,
        completionHandler: Result<Response, T, NSError> -> (),
        queue: dispatch_queue_t?)
    {
        dispatch_async(queue ?? dispatch_get_main_queue(), {
            let message = "FAILURE: Network unavailable."
            let error = Error.redes_errorWithCode(RedesStatusCode.PhysicalError.rawValue, failureReason: message)
            let rsp = Response(
                setup: setup,
                data: nil,
                response: nil,
                message: message,
                statusCode: RedesStatusCode.PhysicalError.rawValue
            )
            completionHandler(.Failure(rsp, error))
        })
    }
}
