//
//  Responseable.swift
//  Redes
//
//  Created by Moch Xiao on 11/3/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

internal enum RedesStatusCode: Int {
    /// Note: -32768 can not be used for server response code
    case AssumeSuccess              = -32768
    /// Request error, server can not handle request or server did not receive request.
    case PhysicalError              = -32767 // 404, 408, ...
    case CouldNotGetResponseData    = -32766
    case CouldNotUnwrapCodeField    = -32765
    case CouldNotUnwrapResultField  = -32764
}

public extension NSError {
    var isFatalError: Bool {
        return code == RedesStatusCode.PhysicalError.rawValue
    }
}

public protocol Responseable {
    /// The response code field name
    var responseCodeFieldName: String { get }
    /// The response succes code value
    var responseSuccessCodeValue: Int { get }
    /// The response result field name
    var responseResultFieldName: String { get }
    /// The response message field name
    var responseMessageFieldName: String { get }
    
    /// Validate server response binary data
    /// - Bool: result valid
    /// - String: result
    /// - String: message
    /// - RedesStatusCode: code
    var responseDataValidation: NSData -> (Bool, NSData, String, Int) { get }
    /// Validate server response string
    var responseStringValidation: String -> (Bool, String, String, Int) { get }
    /// Validate server response JSON
    var responseJSONValidation: AnyObject -> (Bool, AnyObject, String, Int) { get }
    /// Validate server response PList
    var responsePropertyListValidation: AnyObject -> (Bool, AnyObject, String, Int) { get }
}

public extension Responseable {
    /// Simply return received data.
    var responseDataValidation: NSData -> (Bool, NSData, String, Int) {
        let validationClosure: NSData -> (Bool, NSData, String, Int) = {
            return (true, $0, "", RedesStatusCode.AssumeSuccess.rawValue)
        }
        
        return validationClosure
    }
    
    /// Simply return received string.
    var responseStringValidation: String -> (Bool, String, String, Int) {
        let validationClosure: String -> (Bool, String, String, Int) = {
            return (true, $0, "", RedesStatusCode.AssumeSuccess.rawValue)
        }
        
        return validationClosure
    }
    
    var responseJSONValidation: AnyObject -> (Bool, AnyObject, String, Int) {
        let validationClosure: AnyObject -> (Bool, AnyObject, String, Int) = {
            /// Upwrap Int value form json, it may be a String returned by server
            func unwrapIntValueFromJSON(jsonValue: AnyObject, key: String) -> Int? {
                if let value = jsonValue[key] as? String {
                    return Int(value)
                } else if let value = jsonValue[key] as? Int {
                    return value
                }
                return nil
            }

            // Code
            let codeKey = self.responseCodeFieldName
            guard let codeValue = unwrapIntValueFromJSON($0, key: codeKey) else {
                return (false, $0, "FAILURE: Could not get response `\(codeKey)` field value.", RedesStatusCode.CouldNotUnwrapCodeField.rawValue)
            }
            
            // Message
            let messageKey = self.responseMessageFieldName
            let messageValue = $0[messageKey] as? String ?? ""
            
            // Validate code
            let correctCodeValue = self.responseSuccessCodeValue
            if codeValue != correctCodeValue {
                return (false, $0, messageValue, codeValue)
            }
            
            // Result
            let resultKey = self.responseResultFieldName
            guard let resultValue = $0[resultKey] else {
                // Server did not return `result` field value
                return (false, $0, "FAILURE: Could not get response `\(resultKey)` field value.", RedesStatusCode.CouldNotUnwrapResultField.rawValue)
            }
            
            // Success
            return (true, resultValue!, messageValue, correctCodeValue)
        }
        
        return validationClosure
    }

    /// Simply return received Property list data.
    var responsePropertyListValidation: AnyObject -> (Bool, AnyObject, String, Int) {
        let validationClosure: AnyObject -> (Bool, AnyObject, String, Int) = {
            return (true, $0, "", RedesStatusCode.AssumeSuccess.rawValue)
        }
        
        return validationClosure
    }
}

