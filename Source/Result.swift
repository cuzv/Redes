//
//  Result.swift
//  Redes
//
//  Created by Moch Xiao on 11/4/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

public enum Result<R, Value, Error: ErrorType> {
    case Success(R, Value)
    case Failure(R, Error)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .Success:
            return true
        case .Failure:
            return false
        }
    }

    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }
    
    
    /// Returns the associated response
    public var response: R? {
        switch self {
        case .Success(let response, _):
            return response
        case .Failure(let respone, _):
            return respone
        }
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case .Success(_, let value):
            return value
        case .Failure:
            return nil
        }
    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: Error? {
        switch self {
        case .Success:
            return nil
        case .Failure(_, let error):
            return error
        }
    }
}

// MARK: - CustomStringConvertible

extension Result: CustomStringConvertible {
    /// The textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure.
    public var description: String {
        switch self {
        case .Success:
            return "SUCCESS"
        case .Failure:
            return "FAILURE"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension Result: CustomDebugStringConvertible {
    /// The debug textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure in addition to the value or error.
    public var debugDescription: String {
        switch self {
        case .Success(_, let value):
            return "SUCCESS: \(value)"
        case .Failure(_, let error):
            return "FAILURE: \(error)"
        }
    }
}
