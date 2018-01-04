//
//  AccessoryInfo.swift
//  Sample-ExternalAccessory
//
//  Created by NishiokaKohei on 2018/01/04.
//  Copyright © 2018年 Kohey.Nishioka. All rights reserved.
//

import Foundation
import ExternalAccessory

protocol AccessoryInforming {
    var connectedAccessory: EAAccessing? { get }
    var session: EADispatchable? { get }
}

struct AccessoryInfo: AccessoryInforming {
    private let accessory: EAAccessing
    private let protocolString: ProtocolString

    init(accessory: EAAccessing, protocolString: ProtocolString) {
        self.accessory      = accessory
        self.protocolString = protocolString
    }

    var name: String {
        get {
            return accessory.name
        }
    }

    var connectedAccessory: EAAccessing? {
        get {
            return session?.accessory
        }
    }

    var session: EADispatchable? {
        get {
            guard let accessory = accessory as? EAAccessory else {
                return nil
            }
            return EASession(accessory: accessory, forProtocol: protocolString)
        }
    }

    var isValid: Bool {
        get {
            return session?.accessory?.accessible(with: { $0 == self.protocolString }) ?? false
        }
    }

}
