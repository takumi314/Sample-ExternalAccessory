//
//  EACommons.swift
//  Sample-ExternalAccessory
//
//  Created by NishiokaKohei on 2018/01/05.
//  Copyright © 2018年 Kohey.Nishioka. All rights reserved.
//

import Foundation

let TEST_PROTOCOL_NAME = "test"
let BUILD_PROTOCOL_NAME = ""
let RELEASE_PROTOCOL_NAME = ""

let MAX_READ_LENGTH = 4096

enum Result<T> {
    case success(T)
    case failure(NSError)
}

