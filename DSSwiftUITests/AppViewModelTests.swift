//
//  AppViewModelTests.swift
//  DSSwiftUITests
//
//  Created by Matt Gannon on 11/22/21.
//

import XCTest
@testable import DSSwiftUI

class AppViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Make sure we have a logged out state to start each test
        KeychainManager.shared.remove(key: .discogsUserToken)
        KeychainManager.shared.remove(key: .lastFmSessionKey)
        XCTAssertNil(KeychainManager.shared.get(for: .discogsUserToken))
        XCTAssertNil(KeychainManager.shared.get(for: .lastFmSessionKey))
    }

    func testLogIn() throws {
        let viewModel = AppViewModel()
        
        KeychainManager.shared.save(key: .discogsUserToken, string: "123")
        KeychainManager.shared.save(key: .lastFmSessionKey, string: "456")

        let expectation = expectation(description: "Wait for view model to update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(viewModel.discogsToken, "123")
            XCTAssertEqual(viewModel.lastFmKey, "456")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.6)

    }
    
    func testLogOut() throws {
        
        // Save fake keys to make sure AppViewModel is getting keys properly on init
        KeychainManager.shared.save(key: .discogsUserToken, string: "123")
        KeychainManager.shared.save(key: .lastFmSessionKey, string: "456")

        let viewModel = AppViewModel()
        XCTAssertNotNil(viewModel.discogsToken)
        XCTAssertNotNil(viewModel.lastFmKey)

        viewModel.logOutAll()
        
        let expectation = expectation(description: "Wait for vm to update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNil(viewModel.discogsToken)
            XCTAssertNil(viewModel.lastFmKey)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.6)
    }
    
    func testLogOutLastFm() throws {
        
        KeychainManager.shared.save(key: .lastFmSessionKey, string: "123")
        XCTAssertNotNil(KeychainManager.shared.get(for: .lastFmSessionKey))
        
        let viewModel = AppViewModel()
        XCTAssertNotNil(viewModel.lastFmKey)

        viewModel.logOutLastFm()
        XCTAssertNil(KeychainManager.shared.get(for: .lastFmSessionKey))

    }

}
