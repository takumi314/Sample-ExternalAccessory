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

public class ExternalAccessoryDispatcher: NSObject {

    let session: EADispatchable
    let state: AccessoryState
    let maxReadLength: Int

    init(_ session: EADispatchable, state: AccessoryState, maxLength maxReadLength: Int = 4096) {
        self.session        = session
        self.state          = state
        self.maxReadLength  = maxReadLength
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

    func send(_ data: Data) {
        let result = data.withUnsafeBytes {
            return session.output?.write($0, maxLength: data.count)
        }
        guard let code = result else {
            return
        }
        switch code {
        case (-1):
            print(session.output?.streamError?.localizedDescription ?? "Error")
            break
        case (0):
            print("Result 0: A fixed-length stream and has reached its capacity.")
            break
        default:
            print("Result: \(code) bytes written")
            break
        }
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

extension ExternalAccessoryDispatcher: StreamDelegate {
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("new message received")
            readAvailableBytes(aStream as! InputStream, capacity: maxReadLength)
            break
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
            break
        case Stream.Event.errorOccurred:
            print("error occurred")
            break
        case Stream.Event.endEncountered:
            print("new message received")
            stop()
            break
        default:
            print("some other event...")
            break
        }
    }

    private func readAvailableBytes(_ stream: InputStream, capacity length: Int) {
        // set up a buffer, into which you can read the incoming bytes
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: length)

        //  loop for as long as the input stream has bytes to be read
        while stream.hasBytesAvailable {
            // read bytes from the stream and put them into the buffer you pass in
            let numberOfByteRead = stream.read(buffer, maxLength: length)
            // error occured or not
            if numberOfByteRead < 0 {
                let e = stream.streamError
                print(e?.localizedDescription ?? "Error occured")
                break
            }
            // notify interested parties
            if let messageString = processedMessageString(buffer, length: numberOfByteRead) {
                delegate?.receivedMessage(message: messageString)
            }
        }
    }

    private func processedMessageString(_ buffer: UnsafeMutablePointer<UInt8>, length: Int) -> String? {
        guard let string = String(bytesNoCopy: buffer, length: length, encoding: .ascii, freeWhenDone: true) else {
            return nil
        }
        return string
    }

}

