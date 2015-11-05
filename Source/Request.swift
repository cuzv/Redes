//
//  Request.swift
//  Redes
//
//  Created by Moch Xiao on 11/4/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

public class Request {
    internal let originalCommand: protocol<Requestable, Responseable>
    private(set) var originalUploadCommand: Uploadable?
    private(set) var originalDownloadCommand: Downloadable?
    
    var request: Alamofire.Request?

    deinit {
    }
    
    init(command: protocol<Requestable, Responseable>) {
        originalCommand = command
        sendCommand()
    }
    
    init(command: protocol<Requestable, Responseable, Uploadable>) {
        originalCommand = command
        originalUploadCommand = command
        sendCommand()
    }
    
    init(command: protocol<Requestable, Responseable, Downloadable>) {
        originalCommand = command
        originalDownloadCommand = command
        sendCommand()
    }
    
    init(command: protocol<Requestable, Responseable, Uploadable, Downloadable>) {
        originalCommand = command
        originalUploadCommand = command
        originalDownloadCommand = command
        sendCommand()
    }
}

// MARK: - Send request and cancel request
public extension Request {
    private func sendCommand() {
        debugPrint(self)
        
        Alamofire.Manager.sharedInstance.session.configuration.timeoutIntervalForRequest = originalCommand.requestTimeoutInterval
        
        let method = originalCommand.requestMethod.method()
        let requestURLPath = originalCommand.requestURLPath
        let requestHeaderParameters = originalCommand.requestHeaderParameters
        
        if let uploaCommand = originalUploadCommand {
            // Need download
            if !uploaCommand.validateUpload {
                fatalError("You must implement one of protocol `Uploadable` `uploadXXX` methods.")
            }
            
            if let uploadFileURL = originalUploadCommand?.uploadFileURL {
                request = Alamofire.upload(
                    method,
                    requestURLPath,
                    headers: requestHeaderParameters,
                    file: uploadFileURL
                )
                return
            } else if let data = originalUploadCommand?.uploadData {
                request = Alamofire.upload(
                    method,
                    requestURLPath,
                    headers: requestHeaderParameters,
                    data: data
                )
                return
            } else if let stream = originalUploadCommand?.uploadStream {
                request = Alamofire.upload(
                    method,
                    requestURLPath,
                    headers: requestHeaderParameters,
                    stream: stream
                )
                return
            } else if let (dataClosure, encodingResultClosure, threshold) = originalUploadCommand?.uploadMultipartFormDataTuple {
                Alamofire.upload(
                    method,
                    requestURLPath,
                    headers: requestHeaderParameters,
                    multipartFormData: dataClosure,
                    encodingMemoryThreshold: threshold,
                    encodingCompletion: encodingResultClosure
                )
                return
            }
        } else if let _ = originalDownloadCommand {
            // Need upload
            guard let (resumeData, downloadFileDestination) = originalDownloadCommand?.downloadDestinationTuple else {
                fatalError("You must implement `downloadDestinationTuple` property correct.")
            }
            if let resumeData = resumeData {
                request = Alamofire.download(resumeData: resumeData, destination: downloadFileDestination)
            } else {
                request = Alamofire.download(
                    method,
                    requestURLPath,
                    parameters: originalCommand.requestBodyParameters,
                    encoding: originalCommand.requestParameterEncoding.parameterEncoding(),
                    headers: requestHeaderParameters,
                    destination: downloadFileDestination
                )
            }
            return
        }
        
        // Use Alamofire start networking request
        request = Alamofire.request(
            method,
            requestURLPath,
            parameters: originalCommand.requestBodyParameters,
            encoding: originalCommand.requestParameterEncoding.parameterEncoding(),
            headers: requestHeaderParameters
        )
    }
    
    public func cancel() {
        guard let request = request else {
            return
        }
        
        let state = request.task.state
        if state == .Running || state == .Suspended {
            request.task.cancel()
            debugPrint("Canceling request...")
        }
    }
}

// MARK: - CustomStringConvertible

extension Request: CustomStringConvertible {
    /// The textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure.
    public var description: String {
        return debugDescription
    }
}

// MARK: - CustomDebugStringConvertible

extension Request: CustomDebugStringConvertible {
    /// The debug textual representation used when written to an output stream, which includes the URL request, the URL
    /// response, the server data and the response serialization result.
    public var debugDescription: String {
        var output: [String] = []
        output.append("-------------------------------------------------")
        output.append("requestURLPath: \(originalCommand.requestURLPath)")
        output.append("requestMethod: \(originalCommand.requestMethod)")
        output.append("requestHeaderParameters: \(originalCommand.requestHeaderParameters)")
        output.append("requestBodyParameters: \(originalCommand.requestBodyParameters)")
        output.append("-------------------------------------------------")        
        return output.joinWithSeparator("\n")
    }
}
