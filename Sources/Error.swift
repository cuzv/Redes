//
//  Error.swift
//  Redes
//
//  Created by Moch Xiao on 9/30/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

import Foundation

public enum RedesError: Error {
    public enum ParseFailureReason {
        case formInvalid
        case codeCanNotFound
        case messageCanNotFound
        case dataCanNotFound
    }
    
    public struct BusinessFailedReason {
        public let code: Int
        public let message: String
        public init(code: Int, message: String) {
            self.code = code
            self.message = message
        }
    }
    
    case internalFailed(reason: Error)
    case parseFailed(reason: ParseFailureReason)
    case businessFailed(reason: BusinessFailedReason)
}

extension RedesError {
    public var isNetworkFailed: Bool {
        if case .internalFailed = self { return true }
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
        case .internalFailed(reason: let reason):
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
