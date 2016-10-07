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

// MARK: - MicroShopAPI

protocol MicroShopAPI {
    var moduleName: String { get }
    var className: String { get }
    var APIName: String  { get }
    var APIVersion: String { get }
    var dataSignature: String { get }
}

// MARK: - API 后台规则填充

private let identifier: String = UUID().uuidString
extension MicroShopAPI where Self: Redes.Requestable {
    private var encryptToken: String { return NSLocalizedString("api_token", comment: "") }
    var APIVersion: String { return "v1" }
    
    // http://app.api.haioo.com/{模块名}/{API版本号}/{类名}/{方法名}?{参数k1=v1&k2=v2，注意，所有的v值都要url编码}
    // .GET Alamofire 应该会自动 urlencode
    var url: URLConvertible {
        let path = NSLocalizedString("your_host", comment: "")
        return "\(path)/\(moduleName)/\(APIVersion)/\(className)/\(APIName)"
    }
    
    var dataSignature: String {
        // 数据签名：
        // dataSignature = MD5码：密钥 + URLPath + 请求参数部分(k1=v1&k2=v2)
        // 注意，计算时的顺序要和请求时保持一致
        // 将此签名加入到header头中： Data-Signature:{数据签名值dataSignature}
        return "\(encryptToken)/\(APIVersion)/\(className)/\(APIName)\(bodies.queryString)".md5
    }
    
    var headers: [String: String] {
        // Client-Idcard:客户端唯一身份标识
        // Client-System:客户端系统标识,1 = IOS ,2 = android, 3 = PCWEB
        // Client-App-Version:APP版本号
        // Client-Device-Model：设备类型：如iphone4s,华为C8812等
        // Client-System-Version:系统版本，如IOS 9.0
        // Member-Id：登录用户的ID，没有登录传0（必须）
        // Member-Signature：登录用户的签名，没有传空（必须）
        // Data-Signature：请求的数据签名值（必须）
        return [
            "Client-Idcard": identifier,
            "Client-System": "ios-micro-shop",
            "Client-App-Version": "1.1.0",
            "Client-Device-Model": "iPhone 7,2",
            "Client-System-Version": "iOS 10.0.1",
            "Member-Id": "14441",
            "Member-Signature": "",
            "Data-Signature": dataSignature,
            "Belong-To-Shop-Id": "14441"
        ]
    }
}

// MARK: - Requests

struct LoginViaMobileAPI: MicroShopAPI, Requestable {
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

struct AccountAmountAPI: MicroShopAPI, Requestable {
    var moduleName: String { return "item" }
    var className: String { return "User" }
    var APIName: String  { return "getAmount" }
}

struct ShopInfoAPI: MicroShopAPI, Requestable {
    var moduleName: String { return "item" }
    var className: String { return "Shop" }
    var APIName: String { return "getInfo" }
}

struct SaleDataAPI: MicroShopAPI, Requestable {
    var moduleName: String { return "item" }
    var className: String { return "Shop" }
    var APIName: String { return "getStatDataByTotSaleData" }
}


// MARK: - Download

struct DownloadApi: Downloadable {
    var url: URLConvertible {
        return "http://tse1.mm.bing.net/th?id=OIP.Ma778e8864fbc00cb75e973e2e92905eao2&w=135&h=272&c=7&rs=1&qlt=90&o=4&pid=1.9"
    }
}


// MARK: - Upload

struct UploadApi: Uploadable {
    let data: Data
    
    var url: URLConvertible {
        return NSLocalizedString("upload_url", comment: "")
    }
    
    var element: UploadElement {
        return UploadElement.data(data)
    }
}

struct MultipartUploadApi: MultipartUploadable {
    let data: Data

    var url: URLConvertible {
        return NSLocalizedString("upload_url", comment: "")
    }
    
    var elements: [MultipartUploadElement] {
        let element = MultipartUploadElement(name: "file[]", filename: "test_345909034.png", mimeType: "image/jpeg", raw: .data(data))
        return [element]
    }
}
