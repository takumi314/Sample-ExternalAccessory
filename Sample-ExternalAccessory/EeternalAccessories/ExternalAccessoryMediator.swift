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

    init(_ protocolString: ProtocolString = TEST_PROTOCOL_NAME, initial state: AccessoryState = EAInactive(), manager: EAManagable = EAAccessoryManager.shared(), reciever delegate: EAMediatorDelegate) {
        self.protocolString = protocolString
        self.manager        = manager
        self.state          = state
        self.delegate       = delegate
    }

    convenience init(_ protocolString: ProtocolString, reciever delegate: EAMediatorDelegate) {
        self.init(protocolString, manager: EAAccessoryManager.shared(), reciever: delegate)
    }

    // MARK: - Public methods

    func execute<T>(with data: T, handler: @escaping (Result<T>) -> Void) -> Void {
        state = connect(with: protocolString)
        if state is EAInactive {
            let error = NSError(domain: "No matching protocol", code: 100, userInfo: nil)
            handler(.failure(error))
            return
        } else {
            //
        }
    }

    func execute(handler: ActionHandler?) {
        if let info = ExternalAccessoryMediator.takeAccessoryInfo(with: protocolString, manager: manager) {
            state = connect(with: info, completion: handler)
        } else {
            state = EAInactive()
        }
    }

    func connect(with info: AccessoryInfo, completion: ActionHandler?) -> AccessoryState {
        if let session = ExternalAccessoryMediator.listen(with: protocolString, manager: manager) {
            let dispatcher = ExternalAccessoryDispatcher(session, maxLength: MAX_READ_LENGTH, toDelegate: self)
            return state.connect(with: info, dispatcher: dispatcher, completion: completion)
        } else {
            return EAInactive()
        }
    }

    ///
    /// プロトコルに適合する外部接続機器の接続状態オブジェクトを返す
    ///
    private func connect(with protocolString: ProtocolString) -> AccessoryState {
        let conditional = { (name: String) -> Bool in
            return name == protocolString
        }
        return connect(with: conditional)
    }

    private func dispach(with protocolString: ProtocolString, manager: EAManagable = EAAccessoryManager.shared()) -> ExternalAccessoryDispatcher? {
        guard let session = ExternalAccessoryMediator.listen(with: protocolString, manager: manager) else {
            return nil
        }
        return ExternalAccessoryDispatcher(session, maxLength: MAX_READ_LENGTH, toDelegate: self)
    }

    private static func listen(with protocolString: ProtocolString, manager: EAManagable = EAAccessoryManager.shared()) -> EADispatchable? {
        return ExternalAccessoryMediator.takeAccessoryInfo(with: protocolString, manager: manager)?.session
    }

    static func takeAccessoryInfo(with protocolString: ProtocolString, manager: EAManagable = EAAccessoryManager.shared()) -> AccessoryInfo? {
        guard let accessory = ExternalAccessoryMediator.takeConnectedAccessory(protocolString: protocolString, with: manager)  else {
            return nil
        }
        return AccessoryInfo(accessory: accessory, protocolString: protocolString)
    }

    static func takeConnectedAccessory(protocolString: ProtocolString, with manager: EAManagable = EAAccessoryManager.shared()) -> EAAccessing?  {
        let isIncludedProtocol = { (accessory: EAAccessing) -> Bool in
            return accessory.readProtocolStrings.contains(where: { $0 == protocolString })
        }
        return manager.readConnectedAccessories.filter(isIncludedProtocol).first
    }

    ///
    /// 条件設定: 指定したプロトコルが一致すること
    ///
    private func connect(with name: @escaping (String) -> Bool) -> AccessoryState {
        let conditional = { (accessory: EAAccessing) -> Bool in
            return accessory.accessible(with: name)
        }
        return connect(with: protocolString, conditional: conditional)
    }

    ///
    /// conditional: 一定の条件下で接続先が存在するならば EAActive を生成し, それ以外ならば EAInactive を生成する.
    ///
    private func connect(with protocolString: ProtocolString, conditional: (EAAccessing) -> Bool) -> AccessoryState {
        guard let accessory = connectedAccessories(manager).filter(conditional).first else {
            return EAInactive()
        }
        let info = AccessoryInfo(accessory: accessory, protocolString: protocolString)
        let dispatcher = ExternalAccessoryDispatcher(info.session, maxLength: MAX_READ_LENGTH, toDelegate: self)
        return state.connect(with: info, dispatcher: dispatcher, completion: nil)
    }

    func showBluetoothAccessories(with predicate: NSPredicate?, _ manager: EAManagable) -> Void {
        manager.showAccessoryPicker(withNameFilter: predicate) { error in
            print("Error: \(error.debugDescription)")
        }
    }

    func disconnect() -> Void {
        state = state.disconnect()
    }

    // MARK: - Private propeties

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
}

extension ExternalAccessoryMediator: EAAccessoryDelegate {
    public func accessoryDidDisconnect(_ accessory: EAAccessory) {
        disconnect()
    }
}

extension ExternalAccessoryMediator: EADispatcherDelegate {
    func receivedMessage<T>(message: T) {
        //
    }
}

