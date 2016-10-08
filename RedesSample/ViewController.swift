//
//  ViewController.swift
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

import UIKit
import Redes

class ViewController: UIViewController  {    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = 0
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

    fileprivate var downloadedData: Data?
    @IBAction func handleDownload(_ sender: UIButton) {
        performDownload()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        progressView.progress = 0
    }
}


// Before you run this project, checkout `API.swift` and change the setups to your server configuration.
extension ViewController {
    func performLogin() {
        let loginRequest = LoginAPI().makeRequest()
        debugPrint(loginRequest)
        loginRequest.resume()
//        loginRequest.downloadProgress { (progress: Progress) in
//            debugPrint(progress)
//        }
//        loginRequest.responseJSON(parser: DefaultParser<Any>()) { (resp: DataResponse<Any>) in
//            debugPrint(resp.result)
//        }
//        loginRequest.responseJSON(parser: DefaultParser<[String: Any]>()) { (resp: DataResponse<[String: Any]>) in
//            debugPrint(resp.result)
//        }
        
//        loginRequest.responseJSON { (resp: DataResponse<Any>) in
//            debugPrint(resp.result)
//        }
        
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
//            loginRequest.responseJSON { (resp: DataResponse<Any>) in
//                AccountAmountAPI().action().responseJSON { (resp: DataResponse<Any>) in
//                    debugPrint(resp.result)
//                }
//            }
//        }
    }
    
    
    func perfromUpload() {
        guard let downloadedData = downloadedData else {
            debugPrint("fetch download image data fialure.")
            return
        }
        
        progressView.progress = 0
        
//        let upload = UploadApi(data: downloadedData).makeRequest()
//        upload.uploadProgress { (progress) in
//            debugPrint(progress)
//        }
//        
//        upload.responseJSON { (resp: DataResponse<Any>) in
//            debugPrint(resp.result)
//        }
//        upload.resume()

        
        let upload = MultipartUploadApi(data: downloadedData).makeRequest()
        debugPrint(upload)
        upload.resume { (request: MultipartUploadRequest) in
            request.responseJSON(parser: DefaultParser(dataFieldName: "data")) { (resp: DataResponse<Any>) in
                debugPrint(resp.result)
            }
            
            request.uploadProgress { (progress) in
                self.progressView.progress = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
            }
        }
    }
    
    func performDownload() {
        progressView.progress = 0

        let download = DownloadApi().makeRequest()
        download.downloadProgress { (progress: Progress) in
            self.progressView.progress = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
        }
        download.response { (resp: DefaultDownloadResponse) in
            guard let destinationURL = resp.destinationURL else {
                debugPrint("could not get response destinationURL")
                return
            }
            let data = try! Data(contentsOf: destinationURL)
            self.downloadedData = data
            self.imageView.image = UIImage(data: data)
        }
        download.resume()
    }
    
    func performBatchRequest() {
        let loginApi = LoginAPI()
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
