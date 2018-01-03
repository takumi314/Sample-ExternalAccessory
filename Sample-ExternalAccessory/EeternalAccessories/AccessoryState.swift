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
    func connect(accessory: EAAccessing, session: EADispatchable) -> AccessoryState
    func disconnect() -> AccessoryState
    func stop() -> AccessoryState?
}

// MARK: - Eextenal accessory is active

class EAActive: AccessoryState {
    let accessory: EAAccessing
    let dispatcher: ExternalAccessoryDispatcher

    init(accessory: EAAccessing, dispatcher: ExternalAccessoryDispatcher) {
        self.accessory  = accessory
        self.dispatcher = dispatcher
    }
    func interact(handler: ActionHandler?) -> AccessoryState {
        if let handler = handler {
            return handler(accessory)
        }
        return self
    }
    func connect(accessory: EAAccessing, session: EADispatchable) -> AccessoryState {
        return self
    }
    func disconnect() -> AccessoryState {
        return EAInactive(accessory: accessory)
    }
    func stop() -> AccessoryState? {
        return nil
    }
}

// MARK: - Eextenal accessory is inactive

class EAInactive: AccessoryState {
    let accessory: EAAccessing?

    init(accessory: EAAccessing? = nil) {
        self.accessory   = accessory
    }
    func interact(handler: ActionHandler?) -> AccessoryState {
        guard let handler = handler, let accessory = accessory else {
            assertionFailure("Error: camnot connect")
            return self
        }
        return handler(accessory)
    }
    func connect(accessory: EAAccessing, session: EADispatchable) -> AccessoryState {
        return EAActive(accessory: accessory,
                        dispatcher: ExternalAccessoryDispatcher(session, maxLength: MAX_READ_LENGTH))
    }
    func disconnect() -> AccessoryState {
        return self
    }
    func stop() -> AccessoryState? {
        return nil
    }
}
