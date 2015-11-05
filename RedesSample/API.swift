//
//  API.swift
//  Redes
//
//  Created by Moch Xiao on 11/4/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Redes

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

//struct LoginApi: Requestable, Responseable {
//    var userName: String = ""
//    var passWord: String = ""
//    
//    var requestURLPath: URLStringConvertible {
//        return "http://User.testapi.haioo.com/v2.1"
//    }
//    var requestMethod: Redes.Method {
//        return .POST
//    }
//    var requestBodyParameters: [String: AnyObject] {
//        let jsonString = "{\"data\":{\"classname\":\"User\",\"method\":\"memberLogin\",\"params\":[\"18583221776\",\"000000\",\"2319ab6769d1bb7d294da40c22a480\"],\"user\":\"haioo\"},\"signature\":\"20c25c6f463b2122859fa1d21e6876f2\"}"
//        return ["data": jsonString]
//    }
//    var requestHeaderParameters: [String: String] {
//        return [
//            "CLIENT-APP_VERSION":"2.4.0",
//            "CLIENT-DEVICE-MODEL": "Simulator",
//            "CLIENT-ID-CARD": "2319ab6769d1bb7d294da40c22a480",
//            "CLIENT-PLATFORM": "1",
//            "CLIENT-SYSTEM-VERSION": "9.1",
//            "MEMBER-ID": "859",
//            "MEMBER-SIGNATURE": "3ca0f10a1e5839a2a59b08048469ff59"
//        ]
//    }
//}


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

