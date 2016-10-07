//
//  Redes.swift
//  Redes
//
//  Created by Moch Xiao on 10/6/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

import Foundation

public extension Requestable {
    public func makeRequest() -> DataRequest {
        return DataRequest(request: self)
    }
    
    public func action() -> DataRequest {
        return makeRequest().resume()
    }
}
public extension Uploadable {
    public func makeRequest() -> UploadRequest {
        return UploadRequest(request: self)
    }
    
    public func action() -> UploadRequest {
        return makeRequest().resume()
    }
}

public extension MultipartUploadable {
    public func makeRequest() -> MultipartUploadRequest {
        return MultipartUploadRequest(request: self)
    }
}

public extension Downloadable {
    public func makeRequest() -> DownloadRequest {
        return DownloadRequest(request: self)
    }
    
    public func action() -> DownloadRequest {
        return makeRequest().resume()
    }
}
