//
//  EAAccessory.swift
//  Sample-ExternalAccessory
//
//  Created by NishiokaKohei on 2017/12/26.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

import Foundation
import ExternalAccessory

protocol EAAccessing {
    var name: String { get }
    var isConnected: Bool { get }
    var readProtocolStrings: [String] { get }
    func accessible(with protocolString: @escaping (String) -> Bool) -> Bool
}

extension EAAccessing {}

extension EAAccessory: EAAccessing {

    var name: String {
        get {
            return self.name
        }
    }


    var isConnected: Bool {
        get {
            return self.isConnected
        }
    }
    
    var readProtocolStrings: [String] {
        get {
            return protocolStrings
        }
    }

    ///
    /// @protocolString 外部接続先のプロトコルが含まれるかを判定する関数を指定する.
    /// @return 判定結果がBool型で返される。
    ///
    func accessible(with protocolString: @escaping (String) -> Bool) -> Bool {
        return readProtocolStrings.contains(where: protocolString)
    }

    ///
    /// 接続中の外部接続先で, 指定したプロトコルを含むものがあるか判定する.
    ///
    func contains(protocol name: String) -> Bool {
        return protocolStrings.contains(name)
    }

}
