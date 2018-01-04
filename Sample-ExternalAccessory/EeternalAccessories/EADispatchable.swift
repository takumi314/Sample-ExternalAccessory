//
//  EADispatchable.swift
//  Sample-ExternalAccessory
//
//  Created by NishiokaKohei on 2018/01/01.
//  Copyright © 2018年 Kohey.Nishioka. All rights reserved.
//

import Foundation
import ExternalAccessory

protocol EADispatchable {
    var input: InputStream? { get }
    var output: OutputStream? { get }
    var accessory: EAAccessing? { get }
    var protocolString: ProtocolString? { get }
}

extension EASession: EADispatchable {
    var input: InputStream? {
        return self.inputStream
    }
    var output: OutputStream? {
        return self.outputStream
    }
    var accessory: EAAccessing? {
        return self.accessory
    }
    var protocolString: ProtocolString? {
        return self.protocolString
    }
}
