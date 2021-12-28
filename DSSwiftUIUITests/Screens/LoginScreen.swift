//
//  LoginScreen.swift
//  DSSwiftUIUITests
//
//  Created by Matt Gannon on 12/28/21.
//

import XCTest

protocol Screen {
    var app: XCUIApplication { get }
    associatedtype IdentifierEnum: UITestIdentifier
}

struct LoginScreen: Screen {
    
    typealias IdentifierEnum = LoginIdentifier
    let app: XCUIApplication

    // MARK: - Actions
    func tapLogin() -> ReleaseListScreen {
        app.buttons[IdentifierEnum.loginButton].tap()
        return ReleaseListScreen(app: app)
    }
    
}
