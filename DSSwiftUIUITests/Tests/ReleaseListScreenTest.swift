//
//  ReleaseListScreenTest.swift
//  DSSwiftUIUITests
//
//  Created by Matt Gannon on 12/28/21.
//

import XCTest

final class ReleaseListScreenTest: UITestCase {
    
    func testFiltersTapped() {
        LoginScreen(app: app)
            .tapLogin()
            .tapFilterButton()
            .verifyShowingFilterCategoryScreen()
    }
    
    func testSettingsTapped() {
        LoginScreen(app: app)
            .tapLogin()
            .tapSettingsButton()
            .verifyShowingSettingsContext()
    }
    
}
