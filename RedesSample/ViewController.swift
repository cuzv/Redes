//
//  ViewController.swift
//  RedesSample
//
//  Created by Moch Xiao on 11/3/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import UIKit
import Redes

class SomeClass: Uploadable, Downloadable {
    var uploadFileURL: NSURL? {
        return nil
    }
    var uploadData: NSData? {
        return nil
    }
    var uploadStream: NSInputStream? {
        return nil
    }
    var uploadMultipartFormDataTuple: ((MultipartFormData -> Void), (MultipartFormDataEncodingResult -> Void)?, encodingMemoryThreshold: UInt64)? {
        let dataClosure: (MultipartFormData -> Void) = { multipartFormData -> Void in
            multipartFormData.appendBodyPart(data: NSData(), name: "PartName")
        }
        let encodingResultClosure: (MultipartFormDataEncodingResult -> Void)? = { MultipartFormDataEncodingResult -> Void in
            
        }
        
        return (dataClosure, encodingResultClosure, MultipartFormDataEncodingMemoryThreshold)
    }
    
    // download
    var downloadDestinationTuple: (NSData?, DownloadFileDestination) {
        let downloadFileDestination: DownloadFileDestination = { (url, response) -> NSURL in
            return url
        }
        return (nil, downloadFileDestination)
    }

}

class ViewController: UIViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
        performLogin()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        performLogin()
    }
    
}

extension ViewController {
    func performLogin() {
        let loginApi = LoginApi(userName: "user", passWord: "pass")
        Redes.request(loginApi)
            .responseJSON {
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
    }
}

