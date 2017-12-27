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
    func readProtocolStrings() -> [String]
    func accessible(with protocolName: @escaping (String) -> Bool) -> Bool
    func isConnected() -> Bool
}

extension EAAccessing {}

extension EAAccessory: EAAccessing {

    func readProtocolStrings() -> [String] {
        return protocolStrings
    }

    func isConnected() -> Bool {
        return isConnected
    }

    ///
    /// @protocolName 外部接続先のプロトコルが含まれるかを判定する関数を指定する.
    /// @return 判定結果がBool型で返される。
    ///
    func accessible(with protocolName: @escaping (String) -> Bool) -> Bool {
        return readProtocolStrings().contains(where: protocolName)
    }

    ///
    /// 接続中の外部接続先で, 指定したプロトコルを含むものがあるか判定する.
    ///
    func contains(protocol name: String) -> Bool {
        return protocolStrings.contains(name)
    }

}
