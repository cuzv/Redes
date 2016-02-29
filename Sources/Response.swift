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
    public let originalSetup: protocol<Requestable, Responseable>
    /// The data returned by the server.
    public let data: NSData?
    /// The server's response to the URL request.
    public let URLResponse: NSHTTPURLResponse?
    /// The message returned by the server or constructed internal.
    public let message: String?
    /// The status code returned by the server or constructed internal.
    /// If Success will always be `RedesStatusCode.Success.rawValue`, which is `-32768`
    public let statusCode: Int?

    public init(
        setup: protocol<Requestable, Responseable>,
        data: NSData?,
        response: NSHTTPURLResponse?,
        message: String?,
        statusCode: Int?)
    {
        originalSetup = setup
        self.data = data
        self.URLResponse = response
        self.message = message
        self.statusCode = statusCode
    }
}
