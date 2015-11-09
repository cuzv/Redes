//
//  Redes.swift
//  Redes
//
//  Created by Moch Xiao on 11/3/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

/// T: protocol<Requestable, Responseable>
public func request<T: protocol<Requestable, Responseable>>(setup: T) -> Request {
    return Request(setup: setup)
}

/// T: protocol<Requestable, Responseable, Uploadable>
public func request<T: protocol<Requestable, Responseable, Uploadable>>(setup: T) -> Request {
    return Request(setup: setup)
}

/// T: protocol<Requestable, Responseable, Downloadable>
public func request<T: protocol<Requestable, Responseable, Downloadable>>(setup: T) -> Request {
    return Request(setup: setup)
}
