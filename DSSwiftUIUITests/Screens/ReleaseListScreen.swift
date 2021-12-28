//
//  ReleaseListScreen.swift
//  DSSwiftUIUITests
//
//  Created by Matt Gannon on 12/28/21.
//

import XCTest

struct ReleaseListScreen: Screen {
    
    typealias IdentifierEnum = ReleaseListIdentifier
    let app: XCUIApplication
    
    // MARK: - Verifications
    func verifyShowingReleaseListScreen() {
        let loggedIn = app.staticTexts["Collection"].waitForExistence(timeout: 3)
        XCTAssert(loggedIn)
    }
    
    func verifyShowingSettingsContext() {
        XCTAssert(app.buttons["Log Out"].exists)
    }
    
    // MARK: - Actions
    func tapFilterButton() -> FilterCategoryScreen {
        app.buttons["Filter"].tap()
        return FilterCategoryScreen(app: app)
    }
    
    func tapSettingsButton() -> Self {
        app.navigationBars.element.buttons["gearshape.fill"].tap()
        return self
    }
    
    func tapLastFmLoginButton() -> LastFmLoginScreen {
        app.buttons["Last.FM Login"].tap()
        return LastFmLoginScreen(app: app)
    }
    
    func tapFirstListItem() -> ReleaseDetailScreen {
        app.tables[IdentifierEnum.releaseList].tap()
        return ReleaseDetailScreen(app: app)
    }
    
}
