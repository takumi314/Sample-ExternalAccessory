//
//  ExternalAccessoryDispatcher.swift
//  Sample-ExternalAccessory
//
//  Created by NishiokaKohei on 2017/12/29.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

import Foundation
import ExternalAccessory

protocol EADispatchable {
    var input: InputStream? { get }
    var output: OutputStream? { get }
    var accessory: EAAccessory? { get }
    var protocolName: ProtocolName? { get }
}

extension EASession: EADispatchable {
    var input: InputStream? {
        return self.inputStream
    }
    var output: OutputStream? {
        return self.outputStream
    }
    var accessory: EAAccessory? {
        return self.accessory
    }
    var protocolName: ProtocolName? {
        return self.protocolString
    }
}

protocol EADispatcherDelegate {
    func receivedMessage<T>(message: T)
}

class ExternalAccessoryDispatcher: NSObject {

    let session: EADispatchable
    let state: AccessoryState

    init(_ session: EADispatchable, state: AccessoryState) {
        self.session    = session
        self.state      = state
    }

    // MARK: - Public properties

    var protocolString: String {
        return session.protocolName ?? ""
    }

    var delegate: EADispatcherDelegate?


    // MARK: - Public methods

    func setupNetworkCommunication() {
        session.input?.delegate = self
        session.output?.delegate = self

        session.input?.schedule(in: .current, forMode: .commonModes)
        session.output?.schedule(in: .current, forMode: .commonModes)

        start()
    }

    // MARK: Private properies

    private var accessory: EAAccessory {
        return session.accessory!
    }

    private var input: InputStream {
        return session.input!
    }

    private var output: OutputStream {
        return session.output!
    }

    // MARK: - Private methods

    func start() {
        session.input?.open()
        session.output?.open()
    }

    func stop() {
        session.input?.close()
        session.output?.close()
    }
}

extension ExternalAccessoryDispatcher {

}
