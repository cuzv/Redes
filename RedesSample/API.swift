//
//  API.swift
//  Redes
//
//  Created by Moch Xiao on 11/4/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Redes

// MARK: - Resonse JSON asynchronous

public extension Redes.Request  {
    public func asyncResponseJSON(completionHandler: Result<Response, AnyObject, NSError> -> ())
        -> Self
    {
        responseJSON(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completionHandler: completionHandler)
        return self
    }
}

// MARK: - API setups

/// ATTENTION: change to your api setup
public extension Responseable {
    var responseCodeFieldName: String {
        return "code"
    }
    var responseSuccessCodeValue: Int {
        return 0
    }
    var responseResultFieldName: String {
        return "result"
    }
    var responseMessageFieldName: String {
        return "msg"
    }
}

/// ATTENTION: change to your api setup
struct LoginApi: Requestable, Responseable {
    var userName: String = ""
    var passWord: String = ""
    
    var requestURLPath: URLStringConvertible {
        return "https://host/to/path"
    }
    var requestMethod: Redes.Method {
        return .POST
    }
    var requestBodyParameters: [String: AnyObject] {
        return [
            "user": userName,
            "pass": passWord
        ]
    }
}


