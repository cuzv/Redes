//
//  Response.swift
//  Redes
//
//  Created by Moch Xiao on 11/4/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

public struct Response {
    /// The request sent to the server.
    public let originalCommand: protocol<Requestable, Responseable>
    /// The data returned by the server.
    public let originalData: NSData?
    /// The message returned by the server.
    public let originalMessage: String?
    /// The status code returned by the server.
    public let originalStatusCode: Int?
    
    public init(command: protocol<Requestable, Responseable>, data: NSData?, message: String?, statusCode: Int?) {
        originalCommand = command
        originalData = data
        originalMessage = message
        originalStatusCode = statusCode
    }
}
