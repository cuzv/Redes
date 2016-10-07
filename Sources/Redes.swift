//
//  Redes.swift
//  Redes
//
//  Created by Moch Xiao on 10/6/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

import Foundation

public extension DataRequest {
    public func resume() -> Self {
        return RedesRequestSender.shared.add(self)
    }
    
    public func cancel() -> Self {
        return RedesRequestSender.shared.remove(self)
    }
    
    public func suspend() -> Self {
        return RedesRequestSender.shared.suspend(self)
    }
}
