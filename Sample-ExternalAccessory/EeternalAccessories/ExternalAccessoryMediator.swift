//
//  ExternalAccessoryMediator.swift
//  Sample-ExternalAccessory
//
//  Created by NishiokaKohei on 2017/12/24.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

import Foundation
import ExternalAccessory

let TEST_PROTOCOL_NAME = "test"
let BUILD_PROTOCOL_NAME = ""
let RELEASE_PROTOCOL_NAME = ""

let MAX_READ_LENGTH = 4096


enum Result<T> {
    case success(T)
    case failure(NSError)
}

typealias ProtocolString = String
typealias ActionDispatcher<T> = (ExternalAccessoryDispatcher) -> Result<T>

protocol EAMediatorDelegate {
    func receivedMessage<T>(message: T)
}

open class ExternalAccessoryMediator: NSObject {

    let protocolString: ProtocolString

    var state: AccessoryState
    var isActive: Bool {
        get {
            return state is EAActive
        }
    }

    // MARK: - Initializer

    init(_ protocolString: ProtocolString = TEST_PROTOCOL_NAME, initial state: AccessoryState = EAInactive(), manager: EAManagable = EAAccessoryManager.shared(), reciever delegate: EAMediatorDelegate?) {
        self.protocolString = protocolString
        self.manager        = manager
        self.state          = state
        self.delegate       = delegate
    }

    convenience init(_ protocolString: ProtocolString, reciever delegate: EAMediatorDelegate) {
        self.init(protocolString, manager: EAAccessoryManager.shared(), reciever: delegate)
    }


    // MARK: - Public methods

    func showBluetoothAccessories(with predicate: NSPredicate?, _ manager: EAManagable) -> Void {
        manager.showAccessoryPicker(withNameFilter: predicate) { error in
            print("Error: \(error.debugDescription)")
        }
    }

    func disconnect() -> Void {
        state = state.disconnect()
    }

    func execute(handler: ActionHandler?) {
        execute(protocolString: protocolString, manager: manager, handler: handler)
    }

    func connect(with info: AccessoryInfo, completion: ActionHandler?) -> AccessoryState {
        return connect(with: info, manager: manager, completion: completion)
    }



    // MARK: - Private propetiesK

    private let manager: EAManagable

    ///
    /// 接続中の外部接続先を返します  () -> [EAAccessory]
    ///
    private let connectedAccessories = { (manager: EAManagable) -> [EAAccessing] in
        return manager.readConnectedAccessories
    }

    private var connectedAccessory: (EAAccessing) -> Bool = { accessory in
        return accessory.isConnected
    }

    private var delegate: EAMediatorDelegate?

    // MARK: - Private methods

    private func execute(protocolString: ProtocolString, manager: EAManagable = EAAccessoryManager.shared(), handler: ActionHandler?) {
        if let info = ExternalAccessoryMediator.takeAccessoryInfo(with: protocolString, manager: manager) {
            state = connect(with: info, manager: manager, completion: handler)
        } else {
            state = EAInactive()
        }
    }

    private func connect(with info: AccessoryInfo, manager: EAManagable = EAAccessoryManager.shared(), completion: ActionHandler?) -> AccessoryState {
        if let session = ExternalAccessoryMediator.lookSession(with: protocolString, manager: manager) {
            let dispatcher = ExternalAccessoryDispatcher(session, maxLength: MAX_READ_LENGTH, reciever: self)
            return state.connect(with: info, dispatcher: dispatcher, completion: completion)
        } else {
            return EAInactive()
        }
    }

    private func dispatch(with protocolString: ProtocolString, manager: EAManagable = EAAccessoryManager.shared()) -> ExternalAccessoryDispatcher? {
        guard let session = ExternalAccessoryMediator.lookSession(with: protocolString, manager: manager) else {
            return nil
        }
        return ExternalAccessoryDispatcher(session, maxLength: MAX_READ_LENGTH, reciever: self)
    }

    private static func lookSession(with protocolString: ProtocolString, manager: EAManagable = EAAccessoryManager.shared()) -> EADispatchable? {
        return ExternalAccessoryMediator.takeAccessoryInfo(with: protocolString, manager: manager)?.session
    }

    private static func takeAccessoryInfo(with protocolString: ProtocolString, manager: EAManagable = EAAccessoryManager.shared()) -> AccessoryInfo? {
        guard let accessory = ExternalAccessoryMediator.takeConnectedAccessory(protocolString: protocolString, with: manager) else {
            return nil
        }
        return AccessoryInfo(accessory: accessory, protocolString: protocolString)
    }

    ///
    /// プロトコルを指定して, 接続中の外部接続端末の中で適合する EAAccessory を１つ取得する
    ///
    private static func takeConnectedAccessory(protocolString: ProtocolString, with manager: EAManagable = EAAccessoryManager.shared()) -> EAAccessing?  {
        let isIncludedProtocol = { (accessory: EAAccessing) -> Bool in
            return accessory.readProtocolStrings.contains(where: { $0 == protocolString })
        }
        return manager.readConnectedAccessories.filter(isIncludedProtocol).first
    }

}

extension ExternalAccessoryMediator: EAAccessoryDelegate {
    public func accessoryDidDisconnect(_ accessory: EAAccessory) {
        disconnect()
    }
}

extension ExternalAccessoryMediator: EADispatcherDelegate {
    func receivedMessage<T>(message: T) {
        delegate?.receivedMessage(message: message)
    }
}

