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
        // Make sure we have a logged out state to start each test
        KeychainManager.shared.remove(key: .discogsUserToken)
        KeychainManager.shared.remove(key: .lastFmSessionKey)
        XCTAssertNil(KeychainManager.shared.get(for: .discogsUserToken))
        XCTAssertNil(KeychainManager.shared.get(for: .lastFmSessionKey))
    }

    func testLogInLogOut() throws {
        
        // Save fake keys to make sure AppViewModel is getting keys properly on init
        KeychainManager.shared.save(key: .discogsUserToken, string: "123")
        KeychainManager.shared.save(key: .lastFmSessionKey, string: "123")
        XCTAssertNotNil(KeychainManager.shared.get(for: .discogsUserToken))
        XCTAssertNotNil(KeychainManager.shared.get(for: .lastFmSessionKey))

        let viewModel = AppViewModel()
        XCTAssertNotNil(viewModel.discogsToken)
        XCTAssertNotNil(viewModel.lastFmKey)

        viewModel.logOutAll()
        XCTAssertNil(KeychainManager.shared.get(for: .discogsUserToken))
        XCTAssertNil(KeychainManager.shared.get(for: .lastFmSessionKey))
        XCTAssertNil(viewModel.discogsToken)
        XCTAssertNil(viewModel.lastFmKey)

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
