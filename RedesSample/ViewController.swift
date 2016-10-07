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
    }

    @IBAction func handleSingleRequest(_ sender: UIButton) {
        performLogin()
    }
    
    @IBAction func handleBatchRequest(_ sender: UIButton) {
        performBatchRequest()
    }
    
    @IBAction func handleUpload(_ sender: UIButton) {
        perfromUpload()
    }

    fileprivate var downloadUrl: URL?
    @IBAction func handleDownload(_ sender: UIButton) {
        performDownload()
    }
}



// Before you run this project, checkout `API.swift` and change the setups to your server configuration.
extension ViewController {
    
    
    func performLogin() {
        
        let loginRequest = LoginViaMobileAPI().makeRequest()
        debugPrint(loginRequest)
        loginRequest.resume()
//        loginRequest.downloadProgress { (progress: Progress) in
//            debugPrint(progress)
//        }
//        loginRequest.responseJSON(parser: DefaultParser<[String: Any], Any>()) { (resp: DataResponse<Any>) in
//            debugPrint(resp.result)
//        }
//        loginRequest.responseJSON(parser: DefaultParser<[String: Any], [String: Any]>()) { (resp: DataResponse<[String: Any]>) in
//            debugPrint(resp.result)
//        }
        
//        loginRequest.responseJSON { (resp: DataResponse<Any>) in
//            debugPrint(resp.result)
//        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            loginRequest.responseJSON { (resp: DataResponse<Any>) in
                AccountAmountAPI().action().responseJSON { (resp: DataResponse<Any>) in
                    debugPrint(resp.result)
                }
            }
        }
    }
    
    
    func perfromUpload() {
        guard let downloadUrl = downloadUrl else {
            debugPrint("fetch download url fialure.")
            return
        }
        let data = try! Data(contentsOf: downloadUrl)
//        let upload = UploadApi(data: data).makeRequest()
//        upload.uploadProgress { (progress) in
//            debugPrint(progress)
//        }
//        
//        upload.responseJSON { (resp: DataResponse<Any>) in
//            debugPrint(resp.result)
//        }
//        upload.resume()
        
        let upload = MultipartUploadApi(data: data).makeRequest()
        upload.resume { (request: MultipartUploadRequest) in
            request.responseJSON { (resp: DataResponse<Any>) in
                debugPrint(resp.result)
            }
        }
        
//        testUpload(with: data)
    }
    
    func performDownload() {
        let download = DownloadApi().makeRequest()
        download.downloadProgress { (progress) in
            debugPrint(progress)
        }
        download.response { (resp: DefaultDownloadResponse) in
            self.downloadUrl = resp.destinationURL
            debugPrint(self.downloadUrl)
        }
        download.resume()
    }
    
    func performBatchRequest() {
        let loginApi = LoginViaMobileAPI()
        let accountAmountAPI = AccountAmountAPI()
        let shopInfoAPI = ShopInfoAPI()
        let saleDataAPI = SaleDataAPI()
        
        let batch = BatchRequest(requests: [loginApi, accountAmountAPI, shopInfoAPI, saleDataAPI])
        batch.resume()
        
        batch.responseJSON { (rsps: [DataResponse<Any>]) in
            for element in rsps {
                debugPrint(element.request?.url)
            }
        }
    }
}
