//
//  ExternalAccessoryMediator.swift
//  Sample-ExternalAccessary
//
//  Created by NishiokaKohei on 2017/12/24.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

import Foundation
import ExternalAccessory

enum Result<T> {
    case success(T)
    case failure(NSError)
}

typealias ProtocolName = String

open class ExternalAccessoryMediator: NSObject {

    let isAutomatic: Bool
    let protocolName: ProtocolName

    var state: AccessoryState
    var isActive: Bool {
        get {
            return state is EAActive
        }
    }

    // MARK: - Initializer

    init(_ protocolName: ProtocolName = "No protocol", manager: EAManagable = EAAccessoryManager.shared(), automatic: Bool = false) {
        self.protocolName   = protocolName
        self.manager        = manager
        self.state          = EAInactive(manager: manager)
        self.isAutomatic    = automatic
    }

    // MARK: - Public methods

    func execute<T>(with data: T, handler: @escaping (Result<T>) -> Void) -> Void {
        let state = connect(with: protocolName)
        if state is EAInactive {
            let error = NSError(domain: "No matching protocol", code: 100, userInfo: nil)
            handler(.failure(error))
            return
        } else {
            self.state = state
        }
        if isAutomatic {
            handler(.success(data))
        }
    }

    ///
    /// プロトコルに適合する外部接続機器の接続状態オブジェクトを返す
    ///
    private func connect(with protocolName: ProtocolName) -> AccessoryState {
        let conditional = { (name: String) -> Bool in
            return name == protocolName
        }
        return connect(with: conditional)
    }

    ///
    /// 条件設定: 指定したプロトコルが一致すること
    ///
    private func connect(with name: @escaping (String) -> Bool) -> AccessoryState {
        let conditional = { (accessory: EAAccessing) -> Bool in
            return accessory.accessible(with: name)
        }
        return connect(conditional: conditional)
    }

    ///
    /// conditional: 一定の条件下で接続先が存在するならば EAActive を生成し, それ以外ならば EAInactive を生成する.
    ///
    private func connect(conditional: (EAAccessing) -> Bool) -> AccessoryState {
        guard let accessory = connectedAccessories(manager).filter(conditional).first else {
            return EAInactive(manager: manager, accessory: nil)
        }
        return EAActive(manager: manager, accessory: accessory)
    }

    func showBluetoothAccessories(with predicate: NSPredicate?, _ manager: EAManagable) -> Void {
        manager.showAccessoryPicker(withNameFilter: predicate) { error in
            print("Error: \(error.debugDescription)")
        }
    }

    func disconnect() -> Void {
        self.state = state.disconnect(manager: manager, accessory: nil)
    }

    // MARK: - Private propeties

    private let manager: EAManagable

    ///
    /// 接続中の外部接続先を返します  () -> [EAAccessory]
    ///
    private let connectedAccessories = { (manager: EAManagable) -> [EAAccessing] in
        return manager.readConnectedAccessories()
    }

    private var connectedaccessory: (EAAccessing) -> Bool = { accessory in
        return accessory.isConnected()
    }

}

extension ExternalAccessoryMediator: EAAccessoryDelegate {
    public func accessoryDidDisconnect(_ accessory: EAAccessory) {
        disconnect()
    }
}



