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
    /// To provide a EASession instance which is with arguments of EAAccessing and ProtocolString.
    ///
    static func create(accessory: EAAccessing, forProtocol protocolString: ProtocolString) -> EASession? {
        guard let accessory = accessory as? EAAccessory else {
            return nil
        }
        return EASession(accessory: accessory, forProtocol: protocolString)
    }

}
