//
//  API.swift
//  Redes
//
//  Created by Moch Xiao on 11/4/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Redes

// MARK: - API setups

///// ATTENTION: change to your api setup
//struct LoginApi: Requestable, Responseable {
//    var userName: String = ""
//    var passWord: String = ""
//    
//    var requestURLPath: URLStringConvertible {
//        return "https://host/to/path"
//    }
//    var requestMethod: Redes.Method {
//        return .POST
//    }
//    var requestBodyParameters: [String: AnyObject] {
//        return [
//            "user": userName,
//            "pass": passWord
//        ]
//    }
//}
//
//
///// ATTENTION: change to your api setup
//struct UploadApi: Requestable, Responseable, Uploadable {
//    var requestURLPath: URLStringConvertible {
//        return "https://host/to/path"
//    }
//    
//    var requestMethod: Redes.Method {
//        return .POST
//    }
//    
//    var multipartFormData: (MultipartFormData -> ())? {
//        return { (data) -> () in
//            /// ATTENTION: Add Image
//            let image = UIImage(named: "blank")!
//            let imageData = UIImageJPEGRepresentation(image, 1)!
//            data.appendBodyPart(data:imageData , name: "file", fileName: "test_345909034.png", mimeType: "image/jpeg")
//        }
//    }
//    
//    var responseResultFieldName: String {
//        return "data"
//    }
//    
//    var completionHandler: ((Redes.Request) -> ())? {
//        return { (request) -> () in
//            request.asyncResponseJSON({ (result) in
//                debugPrint(result)
//            })
//        }
//    }
//}
//
//struct DownloadApi: Requestable, Responseable, Downloadable {
//    var requestURLPath: URLStringConvertible {
//        return "http://tse1.mm.bing.net/th?id=OIP.Ma778e8864fbc00cb75e973e2e92905eao2&w=135&h=272&c=7&rs=1&qlt=90&o=4&pid=1.9"
//    }
//}
//
// MARK: - 

struct LoginViaMobileAPI: MicroShopAPI, DataRequest {
    var mobile: String = "13477777777"
    var smsCaptcha: String = "123456"
    
    var moduleName: String { return "item" }
    var className: String { return "User" }
    var APIName: String { return "loginByMobile" }
    
    var method: HTTPMethod { return .post }
    var bodies: [String : Any] {
        return [
            "mobile": mobile,
            "smsCaptcha": smsCaptcha
        ]
    }

}

struct AccountAmountAPI: MicroShopAPI, DataRequest {
    var moduleName: String { return "item" }
    var className: String { return "User" }
    var APIName: String  { return "getAmount" }
}

struct ShopInfoAPI: MicroShopAPI, DataRequest {
    var moduleName: String { return "item" }
    var className: String { return "Shop" }
    var APIName: String { return "getInfo" }
}

struct SaleDataAPI: MicroShopAPI, DataRequest {
    var moduleName: String { return "item" }
    var className: String { return "Shop" }
    var APIName: String { return "getStatDataByTotSaleData" }
}
