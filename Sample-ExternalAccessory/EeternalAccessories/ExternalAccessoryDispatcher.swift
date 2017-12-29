//
//  ExternalAccessoryDispatcher.swift
//  Sample-ExternalAccessory
//
//  Created by NishiokaKohei on 2017/12/29.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

import Foundation
import ExternalAccessory

protocol Dispatchable {

}

protocol EADispatcherDelegate {
    func receivedMessage<T>(message: T)
}

    let session: EASession

    init(_ session: EASession) {
        self.session = session
    }

    // MARK: - Public properties

    var protocolString: String {
        return session.protocolString ?? ""
    }

    // MARK: Private properies

    private var accessory: EAAccessory {
        return session.accessory!
    }

    private var input: InputStream {
        return session.inputStream!
    }

    private var output: OutputStream {
        return session.outputStream!
    }

}

extension ExternalAccessoryDispatcher {

}
