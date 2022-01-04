//
//  LastFmLoginScreen.swift
//  DSSwiftUIUITests
//
//  Created by Matt Gannon on 12/28/21.
//

import XCTest

struct LastFmLoginScreen: Screen {
    
    let app: XCUIApplication
    
    // MARK: - Actions
    func typeUsername() -> Self {
        _ = app.textFields["username"].waitForExistence(timeout: 1)
        let userField = app.textFields[LastFmIdentifier.usernameField]
        userField.tap()
        userField.typeText("username")
        return self
    }
    
    func typePassword() -> Self {
        _ = app.textFields["password"].waitForExistence(timeout: 1)
        let passField = app.secureTextFields[LastFmIdentifier.passwordField]
        passField.tap()
        passField.typeText("password")
        return self
    }
    
    func tapLoginButton() -> ReleaseListScreen {
        app.buttons[LastFmIdentifier.loginButton].tap()
        return ReleaseListScreen(app: app)
    }
    
}
