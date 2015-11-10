//
//  ViewController.swift
//  RedesSample
//
//  Created by Moch Xiao on 11/3/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import UIKit
import Redes

class ViewController: UIViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performLogin()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        test()
    }
    
}

extension ViewController {
    func performLogin() {
        let loginApi = LoginApi()
        let request = Redes.request(loginApi)
            request.responseJSON {
                debugPrint($0)
            }
            .responseString {
                switch $0 {
                case .Success(_, let string):
                    debugPrint(string)
                case .Failure(_, let error):
                    debugPrint(error)
                }
            }
//            .cancel()
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(NSEC_PER_SEC*1)), dispatch_get_main_queue()) {
//            request.responseString(completionHandler: {
//                debugPrint($0)
//                
//            })
//        }
        
    }
    
    func test() {
    }
}

