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
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        performLogin()
//        perfromUpload()
//        performDownload()
//        performBatchRequest()
    }
    
}



// Before you run this project, checkout `API.swift` and change the setups to your server configuration.
extension ViewController {
    func performLogin() {
        let loginRequest = LoginViaMobileAPI().resume()
//        request.responseJSON(parser: DefaultParser<[String: Any], Any>()) { (resp: DataResponse<Any>) in
//            debugPrint(resp.result)
//        }
//        request.responseJSON(parser: DefaultParser<[String: Any], [String: Any]>()) { (resp: DataResponse<[String: Any]>) in
//            debugPrint(resp.result)
//        }
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
//            loginRequest.responseJSON { (resp: DataResponse<Any>) in
//                debugPrint(resp.result)
//                
//                AccountAmountAPI().resume().responseJSON { (resp: DataResponse<Any>) in
//                    debugPrint(resp.result)
//                }
//                
//            }
//        }
        
        loginRequest.responseJSON { (resp: DataResponse<Any>) in
            debugPrint(resp.result)
            
            AccountAmountAPI().resume().responseJSON { (resp: DataResponse<Any>) in
                debugPrint(resp.result)
            }
            
        }
        
        
        
    }
    
    
    func perfromUpload() {
    }
    
    func performDownload() {
        
    }
    
    func performBatchRequest() {
    }
}
