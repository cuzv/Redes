//
//  Responseable.swift
//  Redes
//
//  Created by Moch Xiao on 11/3/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

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
    /// - Int: code
    var responseDataValidation: NSData -> (Bool, NSData, String, Int) { get }
    /// Validate server response string
    var responseStringValidation: String -> (Bool, String, String, Int) { get }
    /// Validate server response JSON
    var responseJSONValidation: AnyObject -> (Bool, AnyObject, String, Int) { get }
    /// Validate server response PList
    var responsePropertyListValidation: AnyObject -> (Bool, AnyObject, String, Int) { get }
}

internal let RequestFailureStatusCode = -9999
internal let NetworkUnavailableStatusCode = -9998

public extension Responseable {
    /// Simply return received data
    var responseDataValidation: NSData -> (Bool, NSData, String, Int) {
        let validationClosure: NSData -> (Bool, NSData, String, Int) = {
            return (true, $0, "", 0)
        }
        
        return validationClosure
    }
    
    /// Simply return received string
    var responseStringValidation: String -> (Bool, String, String, Int) {
        let validationClosure: String -> (Bool, String, String, Int) = {
            return (true, $0, "", 0)
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
            
            // Message
            let messageKey = self.responseMessageFieldName
            let messageValue = $0[messageKey] as? String ?? ""

            // Code
            let codeKey = self.responseCodeFieldName
            let correctCodeValue = self.responseSuccessCodeValue
            // Validate code
            guard let codeValue = unwrapIntValueFromJSON($0, key: codeKey) where codeValue == correctCodeValue  else {
                return (false, $0, messageValue, RequestFailureStatusCode)
            }
            
            // Result
            let resultKey = self.responseResultFieldName
            guard let resultValue = $0[resultKey] else {
                // Server did not return `result` field value
                return (false, $0, messageValue, RequestFailureStatusCode)
            }
            
            // Success
            return (true, resultValue!, messageValue, codeValue)
        }
        
        return validationClosure
    }

    /// Simply return received string
    var responsePropertyListValidation: AnyObject -> (Bool, AnyObject, String, Int) {
        let validationClosure: AnyObject -> (Bool, AnyObject, String, Int) = {
            return (true, $0, "", 0)
        }
        
        return validationClosure
    }
}

