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

typealias ActionHandler = (ExternalAccessoryDispatching) -> Void

protocol AccessoryState {
    func interact(with info: AccessoryInforming, dispatcher: ExternalAccessoryDispatching, handler: ActionHandler?) -> AccessoryState
    func connect(with info: AccessoryInforming, dispatcher: ExternalAccessoryDispatching, completion: ActionHandler?) -> AccessoryState
    func disconnect() -> AccessoryState
    func stop() -> AccessoryState
}

// MARK: - Eextenal accessory is active

class EAActive: AccessoryState {
    private let info: AccessoryInforming
    private let dispatcher: ExternalAccessoryDispatching
    private let handler: ActionHandler?

    init(info: AccessoryInforming, dispatcher: ExternalAccessoryDispatching, handler: ActionHandler? = nil) {
        self.info       = info
        self.dispatcher = dispatcher
        self.handler    = handler
    }

    func interact(with info: AccessoryInforming, dispatcher: ExternalAccessoryDispatching, handler: ActionHandler?) -> AccessoryState {
        guard let _ = info.connectedAccessory else {
            return EAInactive().interact(with: info, dispatcher: dispatcher, handler: handler)
        }
        dispatcher.connect()
        guard let handler = handler else {
            return self
        }
        handler(dispatcher)
        return self
    }

    func connect(with info: AccessoryInforming, dispatcher: ExternalAccessoryDispatching, completion: ActionHandler? = nil) -> AccessoryState {
        guard let _ = info.connectedAccessory else {
            return EAInactive().connect(with: info, dispatcher: dispatcher, completion: completion)
        }
        if let completion = completion {
            completion(dispatcher)
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

    func execute() -> AccessoryState {
        if let handler = handler {
            handler(dispatcher)
        }
        return self
    }
}

// MARK: - Eextenal accessory is inactive

class EAInactive: AccessoryState {

    func interact(with info: AccessoryInforming, dispatcher: ExternalAccessoryDispatching, handler: ActionHandler?) -> AccessoryState {
        guard let _ = info.connectedAccessory else {
            return connect(with: info, dispatcher: dispatcher, completion: handler)
        }
        guard let handler = handler else {
            return connect(with: info, dispatcher: dispatcher)
        }
        return EAActive(info: info, dispatcher: dispatcher, handler: handler).interact()
    }

    func connect(with info: AccessoryInforming, dispatcher: ExternalAccessoryDispatching, completion: ActionHandler? = nil) -> AccessoryState {
        guard let _ = info.connectedAccessory else {
            print("failed to connect")
            return self
        }
        return EAActive(info: info, dispatcher: dispatcher, handler: completion).execute()
    }

    func disconnect() -> AccessoryState {
        return self
    }

    func stop() -> AccessoryState {
        return self
    }

}
