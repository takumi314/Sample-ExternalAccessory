//
//  ExternalAccessoryMediator.swift
//  Sample-ExternalAccessary
//
//  Created by NishiokaKohei on 2017/12/24.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

import Foundation
import ExternalAccessory

protocol EAMediating {

}

enum Result<T> {
    case success(T)
    case failure(NSError)
}

typealias ProtocolName = String

open class ExternalAccessoryMediator: NSObject {

    let isAutomatic: Bool
    let protocolName: ProtocolName

    var isActive: Bool {
        get {
            return state is EAActive
        }
    }

    // MARK: - Initializer

    init(_ protocolName: String = "No protocol", manager: EAAccessoryManager = .shared(), automatic: Bool = false) {
        self.protocolName   = protocolName
        self.state          = EAInactive(manager: manager)
        self.isAutomatic    = automatic
    }

    // MARK: - Public methods
    func execute<T>(with data: T, handler: @escaping (Result<T>) -> Void) -> Void {
        let state = connect(with: .shared(), name: protocolName)
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
    /// 指定したプロトコルすると, 適合するアクセサリの接続状態を返す
    ///
    func connect(with manager: EAAccessoryManager = .shared(),name protocolName: String) -> AccesoryState {
        let conditional = { (name: String) -> Bool in
            return name == protocolName
        }
        return connect(with: manager, protocol: conditional)
    }

    ///
    /// 条件設定: 指定したプロトコルが一致すること
    ///
    private func connect(with manager: EAAccessoryManager = .shared(),protocol name: @escaping (String) -> Bool) -> AccesoryState {
        let conditional = { (accesory: EAAccessory) -> Bool in
            return accesory.accessible(with: name)
        }
        return connect(manager: manager, conditional: conditional)
    }

    ///
    /// conditional: 一定の条件下で接続先が存在するならば EAActive を生成し, それ以外ならば EAInactive を生成する.
    ///
    private func connect(manager: EAAccessoryManager = .shared(), conditional: (EAAccessory) -> Bool) -> AccesoryState {
        guard let accesory = connectedAccessories(manager).filter(conditional).first else {
            return EAInactive(manager: manager)
        }
        return EAActive(manager: manager, accesory: accesory)
    }

    func showBluetoothAccessories(with predicate: NSPredicate?,
                                  manager: EAAccessoryManager = .shared()) -> Void {
        manager.showBluetoothAccessoryPicker(withNameFilter: predicate) { error in
            print("Error: \(error.debugDescription)")
        }
    }

    func disconnect() -> Void {
        self.state = state.disconnect(manager: .shared(), accesory: nil)
    }

    // MARK: - Private propeties

    ///
    /// 接続中の外部接続先を返します  () -> [EAAccessory]
    ///
    private let connectedAccessories = { (manager: EAAccessoryManager) -> [EAAccessory] in
        return manager.connectedAccessories
    }

    private var state: AccesoryState
    private var connectedAccesory: (EAAccessory) -> Bool = { accesory in
        return accesory.isConnected
    }

}

extension ExternalAccessoryMediator: EAAccessoryDelegate {
    public func accessoryDidDisconnect(_ accessory: EAAccessory) {
        disconnect()
    }
}

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













