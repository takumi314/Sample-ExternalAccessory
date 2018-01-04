//
//  Sample_ExternalAccessoryTests.swift
//  Sample-ExternalAccessoryTests
//
//  Created by NishiokaKohei on 2017/12/23.
//  Copyright © 2017年 Kohey.Nishioka. All rights reserved.
//

import XCTest
import ExternalAccessory
@testable import Sample_ExternalAccessory

class Sample_ExternalAccessaryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    class EAAccessoryMock: EAAccessing {
        var name: String {
            get {
                return "Test"
            }
        }
        var isConnected: Bool {
            get {
                return true
            }
        }
        var readProtocolStrings: [String] {
            get {
                return ["test"]
            }
        }
        func accessible(with protocolString: @escaping (String) -> Bool) -> Bool {
            return readProtocolStrings.contains(where: protocolString)
        }
    }
    class EAAccessoryManagerMock: EAManagable {
        var readConnectedAccessories: [EAAccessing] {
            get {
                let object = EAAccessoryMock()
                return [object]
            }
        }
    }
    class DispatchMock: ExternalAccessoryDispatching {
        func connect() {
            print("connect")
        }
        func close() {
            print("close")
        }
        func send(_ data: Data) {
            print("data: \(data)")
        }
    }
    class SessionMock: EADispatchable {
        var input: InputStream?
        var output: OutputStream?
        var accessory: EAAccessing? {
            return EAAccessoryMock()
        }
        var protocolString: ProtocolString? {
            return TEST_PROTOCOL_NAME
        }
    }
    struct AccessoryInfoMock: AccessoryInforming {
        var connectedAccessory: EAAccessing? {
            return EAAccessoryMock()
        }
        var session: EADispatchable? {
            return SessionMock()
        }
    }

    func testAccessryState() {
        var state: AccessoryState = EAInactive()
        let info = AccessoryInfoMock()
        let dispatcher = DispatchMock()

        state = state.connect(with: info, dispatcher: dispatcher, completion: nil)
        XCTAssertTrue(state is EAActive)

        state = state.disconnect()
        XCTAssertTrue(state is EAInactive)

        state = state.interact(with: info, dispatcher: dispatcher) { (dispatcher) in
            let data = "test".data(using: .utf8)!
            dispatcher.send(data)
        }
        XCTAssertTrue(state is EAActive)

        state = state.disconnect().connect(with: info, dispatcher: dispatcher) { (dispatcher) in
            dispatcher.connect()
            let data = "test".data(using: .utf8)!
            dispatcher.send(data)
            dispatcher.close()
        }
        XCTAssertTrue(state is EAActive)

        state = state.stop()
        XCTAssertTrue(state is EAActive)

        state = state.disconnect().stop().interact(with: info, dispatcher: dispatcher) { (dispatcher) in
            dispatcher.connect()
        }.disconnect()
        XCTAssertTrue(state is EAInactive)
    }

    func testInactiveaccessory() -> Void {
    }

    func testActiveaccessory() -> Void {
    }

}
