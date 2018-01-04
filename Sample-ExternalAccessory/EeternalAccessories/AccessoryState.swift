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

typealias ActionHandler = (ExternalAccessoryDispatcher) -> AccessoryState

protocol AccessoryState {
    func interact(with info: AccessoryInfo, dispatcher: ExternalAccessoryDispatcher, handler: ActionHandler?) -> AccessoryState
    func connect(with info: AccessoryInfo, dispatcher: ExternalAccessoryDispatcher, completion: ActionHandler?) -> AccessoryState
    func disconnect() -> AccessoryState
    func stop() -> AccessoryState
}

// MARK: - Eextenal accessory is active

class EAActive: AccessoryState {
    let info: AccessoryInfo
    let dispatcher: ExternalAccessoryDispatcher
    let handler: ActionHandler?

    init(info: AccessoryInfo, dispatcher: ExternalAccessoryDispatcher, handler: ActionHandler? = nil) {
        self.info       = info
        self.dispatcher = dispatcher
        self.handler    = handler
    }

    func interact(with info: AccessoryInfo, dispatcher: ExternalAccessoryDispatcher, handler: ActionHandler?) -> AccessoryState {
        guard let _ = info.connectedAccessory else {
            return EAInactive().interact(with: info, dispatcher: dispatcher, handler: handler)
        }
        dispatcher.connect()
        guard let handler = handler else {
            return self
        }
        return handler(dispatcher)
    }

    func connect(with info: AccessoryInfo, dispatcher: ExternalAccessoryDispatcher, completion: ActionHandler? = nil) -> AccessoryState {
        guard let _ = info.connectedAccessory else {
            return EAInactive().connect(with: info, dispatcher: dispatcher, completion: completion)
        }
        return self
    }

    func disconnect() -> AccessoryState {
        print("Disconnected")
        return EAInactive()
    }

    func stop() -> AccessoryState {
        dispatcher.close()
        print("Socket is close")
        return self
    }

    func interact() -> AccessoryState {
        return interact(with: info, dispatcher: dispatcher, handler: handler)
    }
}

// MARK: - Eextenal accessory is inactive

class EAInactive: AccessoryState {

    func interact(with info: AccessoryInfo, dispatcher: ExternalAccessoryDispatcher, handler: ActionHandler?) -> AccessoryState {
        guard let _ = info.connectedAccessory else {
            return connect(with: info, dispatcher: dispatcher, completion: handler)
        }
        guard let handler = handler else {
            return connect(with: info, dispatcher: dispatcher)
        }
        return EAActive(info: info, dispatcher: dispatcher, handler: handler).interact()
    }

    func connect(with info: AccessoryInfo, dispatcher: ExternalAccessoryDispatcher, completion: ActionHandler? = nil) -> AccessoryState {
        guard let _ = info.connectedAccessory else {
            print("failed to connect")
            return self
        }
        return EAActive(info: info, dispatcher: dispatcher, handler: completion)
    }
    func disconnect() -> AccessoryState {
        return self
    }
    func stop() -> AccessoryState {
        return self
    }
}
