//
//  Redes.swift
//  Redes
//
//  Created by Moch Xiao on 11/3/15.
//  Copyright © 2015 Moch Xiao. All rights reserved.
//

import Foundation
import Alamofire

public func request<T: protocol<Requestable, Responseable>>(command: T) -> Request {
    return Request(command: command)
}

public func request<T: protocol<Requestable, Responseable, Uploadable>>(command: T) -> Request {
    return Request(command: command)
}

public func request<T: protocol<Requestable, Responseable, Downloadable>>(command: T) -> Request {
    return Request(command: command)
}
