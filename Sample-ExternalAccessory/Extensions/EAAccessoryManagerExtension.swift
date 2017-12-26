//
//  EAAccessoryManagerExtension.swift
//  Sample-ExternalAccessary
//
//  Created by NishiokaKohei on 2017/12/27.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

import Foundation
import ExternalAccessory

protocol EAManagable {
    func readConnectedAccessories() -> [EAAccessing]
    func showAccessoryPicker(withNameFilter predicate: NSPredicate?, completion: EABluetoothAccessoryPickerCompletion?)
}

extension EAManagable {
    func readConnectedAccessories() -> [EAAccessing] {
        return EAAccessoryManager.shared().connectedAccessories
    }
    func showAccessoryPicker(withNameFilter predicate: NSPredicate?, completion: EABluetoothAccessoryPickerCompletion?) {
        EAAccessoryManager.shared().showBluetoothAccessoryPicker(withNameFilter: predicate, completion: completion)
    }
}

extension EAAccessoryManager: EAManagable {
    
}
