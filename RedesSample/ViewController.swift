//
//  ViewController.swift
//  RedesSample
//
//  Created by Moch Xiao on 11/3/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import UIKit

class ViewController: UIViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performLogin()
    }
}

// Before you run this project, checkout `API.swift` and change the setups to your server configuration.
extension ViewController {
    func performLogin() {
        let loginApi = LoginApi()
    
        loginApi.asyncResponseJSON {
            debugPrint($0)
        }        
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
//        .cancel()
    }
}




