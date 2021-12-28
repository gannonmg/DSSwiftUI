//
//  LastFmLoginTests.swift
//  DSSwiftUIUITests
//
//  Created by Matt Gannon on 12/28/21.
//

import XCTest

final class LastFmLoginStateTests: UITestCase {
    
    func testLogin() {
        LoginScreen(app: app)
            .tapLogin()
            .tapSettingsButton()
            .tapLastFmLoginButton()
            .typeUsername()
            .typePassword()
            .tapLoginButton()
            .tapFirstListItem()
            .verifyScrobbleButtonShowing()
    }
    
    func testLoggedOut() {
        LoginScreen(app: app)
            .tapLogin()
            .tapFirstListItem()
            .verifyScrobbleButtonHidden()
    }
    
}
