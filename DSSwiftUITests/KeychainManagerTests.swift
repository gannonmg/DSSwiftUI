//
//  KeychainManagerTests.swift
//  DSSwiftUITests
//
//  Created by Matt Gannon on 11/21/21.
//

import XCTest
@testable import DSSwiftUI

class KeychainManagerTests: XCTestCase {

    // Test that saving and retrieving a value in the keychain manager works
    func testSavingValue() throws {
        KeychainManager.shared.save(key: .testKey, string: "test string")
        let val = KeychainManager.shared.get(for: .testKey)
        XCTAssertNotNil(val)
    }
    
    // Test that deleting a saved value in the keychain manager works
    func testDeletingValue() throws {
        KeychainManager.shared.save(key: .testKey, string: "test string")
        KeychainManager.shared.remove(key: .testKey)
        let val = KeychainManager.shared.get(for: .testKey)
        XCTAssertNil(val)
    }

}
