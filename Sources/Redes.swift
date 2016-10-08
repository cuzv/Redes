//
//  Redes.swift
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

public extension Requestable {
    /// Make a normal data request, paused by default.
    public func makeRequest() -> DataRequest {
        return DataRequest(request: self)
    }
    
    /// Make a normal request and resume immediately.
    public func action() -> DataRequest {
        return makeRequest().resume()
    }
}

public extension Uploadable {
    /// Make a upload request, paused by default.
    public func makeRequest() -> UploadRequest {
        return UploadRequest(request: self)
    }
    
    /// Make a upload request and resume immediately.
    public func action() -> UploadRequest {
        return makeRequest().resume()
    }
}

public extension MultipartUploadable {
    /// Make a upload request, paused by default.
    public func makeRequest() -> MultipartUploadRequest {
        return MultipartUploadRequest(request: self)
    }
}

public extension Downloadable {
    /// Make a download request, paused by default.
    public func makeRequest() -> DownloadRequest {
        return DownloadRequest(request: self)
    }
    
    /// Make a download request and resume immediately.
    public func action() -> DownloadRequest {
        return makeRequest().resume()
    }
}
