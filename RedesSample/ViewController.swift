//
//  ViewController.swift
//  RedesSample
//
//  Created by Moch Xiao on 11/3/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import UIKit
import Redes
//import Alamofire

class ViewController: UIViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        test()
//        Redes.setupDebugModeEnable(true)
    }
//
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
////        performLogin()
////        perfromUpload()
//        performDownload()
////        performBatchRequest()
//        
//    }
    
    
    func test() -> () {
//        let nserror = NSError(domain: "mochxiao.com", code: 1024, userInfo: nil)
//        let error = RedesError.networkFailed(reason: .requestFailed(nserror))
//        let error = RedesError.parseFailed(reason: .codeCanNotFound)
//        let error = RedesError.businessFailed(reason: RedesError.BusinessFailedReason(code: 2333, message: "some reason"))
        
        
//        debugPrint(error)
//        debugPrint(error.localizedDescription)
        
//        Alamofire.request("https://httpbin.org/get").responseJSON { response in
//            print(response.request)  // original URL request
//            print(response.response) // HTTP URL response
//            print(response.data)     // server data
//            print(response.result)   // result of response serialization
//            
//            if let JSON = response.result.value {
//                print("JSON: \(JSON)")
//            }
//        }
        
    }
}



// Before you run this project, checkout `API.swift` and change the setups to your server configuration.
//extension ViewController {
//    func performLogin() {
//        let loginApi = LoginViaMobileAPI()
//        
//    
//        loginApi.asyncResponseJSON {
//            debugPrint($0)
//        }
//        .responseJSON {
//            switch $0 {
//            case .Success(let rsp, _):
//                if let URLResponse = rsp.URLResponse {
//                    let headerFields = URLResponse.allHeaderFields
//                    debugPrint(headerFields)
//                }
//            case .Failure(_, let error):
//                debugPrint(error)
//                if error.isFatalError {
//                    // 404, 408, ...
//                }
//            }
//        }
//
//        loginApi.responseJSON {
//            debugPrint($0)
//        }
//        .responseString {
//            switch $0 {
//            case .Success(_, let string):
//                debugPrint(string)
//            case .Failure(_, let error):
//                debugPrint(error)
//            }
//        }
////        .cancel()
//    }
//    
//    
//    func perfromUpload() {
//        UploadApi().asyncResponseJSON {
//            /// Never run to here
//            debugPrint($0)
//        }
//    }
//    
//    func performDownload() {
//        
//        DownloadApi().response { (req: NSURLRequest?, resp: NSHTTPURLResponse?, data: NSData?, error: NSError?) in
//            debugPrint(error)
//            debugPrint(resp?.suggestedDestination)
//        }
//        .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
//            debugPrint("propress: \(CGFloat(totalBytesRead) / CGFloat(totalBytesExpectedToRead))")
//        }
//    }
//    
//    func performBatchRequest() {
//        
//        let loginApi = LoginViaMobileAPI()
//        let amountApi = AccountAmountAPI()
//        let shopInfoApi = ShopInfoAPI()
//        let saleDataAPI = SaleDataAPI()
//        
//        let batch = BatchRequest(setups: [loginApi, amountApi, shopInfoApi, saleDataAPI])
//        
//        batch.responseJSON { (rsts: [Result<Response, AnyObject, NSError>]) in
//            debugPrint("rsts.count: \(rsts.count)")
//            for rst in rsts {
//                debugPrint(rst)
//            }
//        }.responseString { (rsts: [Result<Response, String, NSError>]) in
//            debugPrint("rsts.count: \(rsts.count)")
//            for rst in rsts {
//                debugPrint(rst)
//            }
//        }
//        
//        let d1 = DownloadApi()
//        let d2 = DownloadApi()
//        
//        let batch2 = BatchRequest(setups: [d1, d2])
//        batch2.response { (rsts: [(NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?)]) in
//            
//        }
//        
//    }
//}
