//
//  ResponseSerialization.swift
//  Redes
//
//  Created by Moch Xiao on 11/4/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Response helper methods

extension Request {
    /// Generate manual failure closure parameters
    func buildFailureResultByResponse<T>(
        response: Alamofire.Response<T, NSError>,
        message: String = "Server response llegal",
        statusCode: Int = RequestFailureStatusCode
        ) -> Result<Response, T, NSError>
    {
        let rsp = Response(
            command: self.originalCommand,
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
        statusCode: Int) -> Result<Response, T, NSError> {
        let rsp = Response(
            command: self.originalCommand,
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
        response: Alamofire.Response<K, NSError>) {
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

// MARK: - Response serialization

public extension Request {
    /// Resposne data
    public func responseData(
        completionHandler: Result<Response, NSData, NSError> -> Void)
        -> Self {
            // Trailing closure
            request?.responseData() {
                self.bridgeToResultCompletionHandler(
                    completionHandler,
                    validationHandler: self.originalCommand.responseDataValidation,
                    response: $0
                )
            }
            
            return self
    }
    
    /// Response strting data
    public func responseString(
        encoding encoding: NSStringEncoding? = nil,
        completionHandler: Result<Response, String, NSError>-> Void)
        -> Self
    {
        request?.responseString(encoding: encoding, completionHandler: {
            self.bridgeToResultCompletionHandler(
                completionHandler,
                validationHandler: self.originalCommand.responseStringValidation,
                response: $0
            )
        })
        
        return self
    }

    /// Response json data
    public func responseJSON(
        options options: NSJSONReadingOptions = .AllowFragments,
        completionHandler: Result<Response, AnyObject, NSError> -> Void)
        -> Self
    {
        request?.responseJSON(options: options, completionHandler: {
            self.bridgeToResultCompletionHandler(
                completionHandler,
                validationHandler: self.originalCommand.responseJSONValidation,
                response: $0
            )
        })

        return self
    }
    
    
    /// Response PList
    public func responsePropertyList(
        options options: NSPropertyListReadOptions = NSPropertyListReadOptions(),
        completionHandler: Result<Response, AnyObject, NSError> -> Void)
        -> Self
    {
        request?.responsePropertyList(options: options, completionHandler: {
            self.bridgeToResultCompletionHandler(
                completionHandler,
                validationHandler: self.originalCommand.responsePropertyListValidation,
                response: $0
            )
        })
        
        return self
    }
}
