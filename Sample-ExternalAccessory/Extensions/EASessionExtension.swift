//
//  EASessionExtension.swift
//  Sample-ExternalAccessory
//
//  Created by NishiokaKohei on 2017/12/28.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

import Foundation
import ExternalAccessory

extension EASession {

    ///
    /// To provide a EASession instance which is with arguments of EAAccessing and ProtocolName.
    ///
    static func create(accessory: EAAccessing, forProtocol protocolString: ProtocolName) -> EASession? {
        return EASession(accessory: accessory, forProtocol: protocolString)
    }

    convenience init?(accessory: EAAccessing, forProtocol protocolString: ProtocolName) {
        if let accessory = accessory as? EAAccessory {
            self.init(accessory: accessory, forProtocol: protocolString)
        } else {
            self.init(accessory: accessory as! EAAccessory, forProtocol: protocolString)
        }
    }

}
