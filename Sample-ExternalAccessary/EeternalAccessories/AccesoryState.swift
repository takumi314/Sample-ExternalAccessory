//
//  AccesoryState.swift
//  Sample-ExternalAccessary
//
//  Created by NishiokaKohei on 2017/12/26.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

import Foundation
import ExternalAccessory

// MARK: - To manage accesory's statement

protocol AccesoryState {
    typealias ActionHandler = (EAAccessory) -> AccesoryState
    func interact(handler: ActionHandler?) -> AccesoryState
    func connect(manager: EAAccessoryManager, accesory: EAAccessory) -> AccesoryState
    func disconnect(manager: EAAccessoryManager, accesory: EAAccessory?) -> AccesoryState
    func stop() -> AccesoryState?
}

// MARK: - Eextenal Accesory is active

class EAActive: AccesoryState {
    let manager: EAAccessoryManager
    let accesory: EAAccessory

    init(manager: EAAccessoryManager, accesory: EAAccessory) {
        self.manager    = manager
        self.accesory   = accesory
    }
    func interact(handler: ActionHandler?) -> AccesoryState {
        if let handler = handler {
            return handler(accesory)
        }
        return self
    }
    func connect(manager: EAAccessoryManager = .shared(), accesory: EAAccessory) -> AccesoryState {
        return self
    }
    func disconnect(manager: EAAccessoryManager, accesory: EAAccessory?) -> AccesoryState {
        return EAInactive(manager: manager, accesory: accesory)
    }
    func stop() -> AccesoryState? {
        return nil
    }
}

// MARK: - Eextenal Accesory is inactive

class EAInactive: AccesoryState {
    let manager: EAAccessoryManager
    let accesory: EAAccessory?

    init(manager: EAAccessoryManager, accesory: EAAccessory? = nil) {
        self.manager    = manager
        self.accesory   = accesory
    }
    func interact(handler: ActionHandler?) -> AccesoryState {
        guard let handler = handler, let accesory = accesory else {
            assertionFailure("Error: camnot connect")
            return self
        }
        return handler(accesory)
    }
    func connect(manager: EAAccessoryManager = .shared(),  accesory: EAAccessory) -> AccesoryState {
        return EAActive(manager: manager, accesory: accesory)
    }
    func disconnect(manager: EAAccessoryManager, accesory: EAAccessory?) -> AccesoryState {
        return self
    }
    func stop() -> AccesoryState? {
        return nil
    }
}
