//
//  API.swift
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
            "Client-Idcard": "AC20B1F4-AB2E-4725-8872-4F9A2999B879",
            "Client-System": "ios-micro-buy",
            "Client-App-Version": "1.4.0",
            "Client-Device-Model": "Simulator",
            "Client-System-Version": "iOS 10.0.1",
            "Member-Id": "859",
            "Member-Signature": "3ca0f10a1e5839a2a59b08048469ff59",
            "Data-Signature": dataSignature,
            "Belong-To-Shop-Id": "859"
        ]
    }
}

// MARK: - Requests

struct LoginAPI: MicroShopAPI, Requestable {
    var mobile: String = "18583221776"
    var password: String = "111111"
    
    var moduleName: String { return "item" }
    var className: String { return "User" }
    var APIName: String { return "login" }
    
    var method: HTTPMethod { return .post }
    var bodies: [String : Any] {
        return [
            "userName": mobile,
            "password": password
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
        return "http://img.test.haioo.com/sns/2016/10/08/9ae5473d339b11aa.png"
    }
}


// MARK: - Upload

struct UploadApi: MicroShopAPI, Uploadable {
    let data: Data
    
    var url: URLConvertible {
        return NSLocalizedString("upload_url", comment: "")
    }
    
    var element: UploadElement {
        return UploadElement.data(data)
    }
    
    var moduleName: String { return "" }
    var className: String { return "" }
    var APIName: String { return "" }
}

struct MultipartUploadApi: MicroShopAPI, MultipartUploadable {
    let data: Data

    var url: URLConvertible {
        return NSLocalizedString("upload_url", comment: "")
    }
    
    var elements: [MultipartUploadElement] {
        let element = MultipartUploadElement(name: "file[]", filename: "test_345909034.png", mimeType: "image/jpeg", raw: .data(data))
        return [element]
    }
    
    var moduleName: String { return "" }
    var className: String { return "" }
    var APIName: String { return "" }
}
