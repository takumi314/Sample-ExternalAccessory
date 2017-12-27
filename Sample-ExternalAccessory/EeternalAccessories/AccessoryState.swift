//
//  accessoryState.swift
//  Sample-ExternalAccessory
//
//  Created by NishiokaKohei on 2017/12/26.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

import Foundation
import ExternalAccessory

// MARK: - To manage accessory's statement

protocol AccessoryState {
    typealias ActionHandler = (EAAccessing) -> AccessoryState
    func interact(handler: ActionHandler?) -> AccessoryState
    func connect(manager: EAManagable, accessory: EAAccessing) -> AccessoryState
    func disconnect(manager: EAManagable, accessory: EAAccessing?) -> AccessoryState
    func stop() -> AccessoryState?
}

// MARK: - Eextenal accessory is active

class EAActive: AccessoryState {
    let manager: EAManagable
    let accessory: EAAccessing

    init(manager: EAManagable = EAAccessoryManager.shared(), accessory: EAAccessing) {
        self.manager    = manager
        self.accessory   = accessory
    }
    func interact(handler: ActionHandler?) -> AccessoryState {
        if let handler = handler {
            return handler(accessory)
        }
        return self
    }
    func connect(manager: EAManagable, accessory: EAAccessing) -> AccessoryState {
        return self
    }
    func disconnect(manager: EAManagable, accessory: EAAccessing?) -> AccessoryState {
        return EAInactive(manager: manager, accessory: accessory)
    }
    func stop() -> AccessoryState? {
        return nil
    }
}

// MARK: - Eextenal accessory is inactive

class EAInactive: AccessoryState {
    let manager: EAManagable
    let accessory: EAAccessing?

    init(manager: EAManagable = EAAccessoryManager.shared(), accessory: EAAccessing? = nil) {
        self.manager    = manager
        self.accessory   = accessory
    }
    func interact(handler: ActionHandler?) -> AccessoryState {
        guard let handler = handler, let accessory = accessory else {
            assertionFailure("Error: camnot connect")
            return self
        }
        return handler(accessory)
    }
    func connect(manager: EAManagable,  accessory: EAAccessing) -> AccessoryState {
        return EAActive(manager: manager, accessory: accessory)
    }
    func disconnect(manager: EAManagable, accessory: EAAccessing?) -> AccessoryState {
        return self
    }
    func stop() -> AccessoryState? {
        return nil
    }
}
