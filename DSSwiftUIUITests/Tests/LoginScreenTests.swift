//
//  LoginScreenTests.swift
//  DSSwiftUIUITests
//
//  Created by Matt Gannon on 12/16/21.
//

import XCTest

final class LoginScreenTests: UITestCase {

    func testLogin() throws {
        LoginScreen(app: app)
            .tapLogin()
            .verifyShowingReleaseListScreen()
    }

}
