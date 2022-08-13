//
//  UITestIdentifiersTests.swift
//  DSSwiftUITests
//
//  Created by Matt Gannon on 12/28/21.
//

@testable import DSSwiftUI
import XCTest

class UITestIdentifiersTests: XCTestCase {

    func testIdentifierValue() throws {
        let identifierString: String = LoginIdentifier.loginButton.identifierString
        XCTAssertEqual(identifierString, "LoginIdentifier.loginButton")
    }

}
