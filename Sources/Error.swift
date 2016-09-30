//
//  Error.swift
//  Redes
//
//  Created by Moch Xiao on 9/30/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

import Foundation

public enum RedesError: Error {
    public enum NetworkFailureReason {
        case requestFailed(Error)
        case responseFailed(Error)
    }
    
    public enum ParseFailureReason {
        case codeCanNotFound
        case codeInvalid
        case messageCanNotFound
        case dataCanNotFound
        case dataCanNotParse
    }
    
    public struct BusinessFailedReason {
        public let code: Int
        public let message: String
        public init(code: Int, message: String) {
            self.code = code
            self.message = message
        }
    }
    
    case networkFailed(reason: NetworkFailureReason)
    case parseFailed(reason: ParseFailureReason)
    case businessFailed(reason: BusinessFailedReason)
}

extension RedesError {
    public var isNetworkFailed: Bool {
        if case .networkFailed = self { return true }
        return false
    }
    
    public var isParseFailed: Bool {
        if case .parseFailed = self { return true }
        return false
    }
    
    public var isBusinessFailed: Bool {
        if case .businessFailed = self { return true }
        return false
    }
}

extension RedesError.NetworkFailureReason {
    public var localizedDescription: String? {
        switch self {
        case .requestFailed(let error), .responseFailed(let error):
            return error.localizedDescription
        }
    }
}

extension RedesError.BusinessFailedReason: CustomStringConvertible {
    public var description: String {
        return "code: \(code), message: \(message)"
    }
}

extension RedesError.BusinessFailedReason: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "code: \(code), message: \(message)"
    }
}

extension RedesError: LocalizedError {
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .networkFailed(reason: let reason):
            return reason.localizedDescription
        case .parseFailed(reason: let reason):
            return "Parse Failed: \(reason)"
        case .businessFailed(reason: let reason):
            return "Business Failed: \(reason)"
        }
    }
}

extension RedesError: CustomStringConvertible {
    public var description: String {
        return localizedDescription
    }
}

extension RedesError: CustomDebugStringConvertible {
    public var debugDescription: String {
        return localizedDescription
    }
}
