//
//  Error.swift
//  Copyright (c) 2015-2016 Moch Xiao (http://mochxiao.com).
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

/// The error for Redes response
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
