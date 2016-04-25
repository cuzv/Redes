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

extension Requestable where Self: Responseable {
    public func asyncResponseJSON(completionHandler: Result<Response, AnyObject, NSError> -> ()) -> Request {
        return Redes.request(self).asyncResponseJSON(completionHandler)
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


/// ATTENTION: change to your api setup
struct UploadApi: Requestable, Responseable, Uploadable {
    var requestURLPath: URLStringConvertible {
        return "https://host/to/path"
    }
    
    var requestMethod: Redes.Method {
        return .POST
    }
    
    var multipartFormData: (MultipartFormData -> ())? {
        return { (data) -> () in
            /// ATTENTION: Add Image
            let image = UIImage(named: "blank")!
            let imageData = UIImageJPEGRepresentation(image, 1)!
            data.appendBodyPart(data:imageData , name: "file", fileName: "test_345909034.png", mimeType: "image/jpeg")
        }
    }
    
    var responseResultFieldName: String {
        return "data"
    }
    
    var completionHandler: ((Redes.Request) -> ())? {
        return { (request) -> () in
            request.asyncResponseJSON({ (result) in
                debugPrint(result)
            })
        }
    }
}


