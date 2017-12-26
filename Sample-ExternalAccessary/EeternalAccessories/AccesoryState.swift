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
    typealias ActionHandler = (EAAccessing) -> AccesoryState
    func interact(handler: ActionHandler?) -> AccesoryState
    func connect(manager: EAManagable, accesory: EAAccessing) -> AccesoryState
    func disconnect(manager: EAManagable, accesory: EAAccessing?) -> AccesoryState
    func stop() -> AccesoryState?
}

// MARK: - Eextenal Accesory is active

class EAActive: AccesoryState {
    let manager: EAManagable
    let accesory: EAAccessing

    init(manager: EAManagable = EAAccessoryManager.shared(), accesory: EAAccessing) {
        self.manager    = manager
        self.accesory   = accesory
    }
    func interact(handler: ActionHandler?) -> AccesoryState {
        if let handler = handler {
            return handler(accesory)
        }
        return self
    }
    func connect(manager: EAManagable, accesory: EAAccessing) -> AccesoryState {
        return self
    }
    func disconnect(manager: EAManagable, accesory: EAAccessing?) -> AccesoryState {
        return EAInactive(manager: manager, accesory: accesory)
    }
    func stop() -> AccesoryState? {
        return nil
    }
}

// MARK: - Eextenal Accesory is inactive

class EAInactive: AccesoryState {
    let manager: EAManagable
    let accesory: EAAccessing?

    init(manager: EAManagable = EAAccessoryManager.shared(), accesory: EAAccessing? = nil) {
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
    func connect(manager: EAManagable,  accesory: EAAccessing) -> AccesoryState {
        return EAActive(manager: manager, accesory: accesory)
    }
    func disconnect(manager: EAManagable, accesory: EAAccessing?) -> AccesoryState {
        return self
    }
    func stop() -> AccesoryState? {
        return nil
    }
}
