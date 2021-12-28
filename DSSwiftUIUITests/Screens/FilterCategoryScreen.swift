//
//  FilterCategoryScreen.swift
//  DSSwiftUIUITests
//
//  Created by Matt Gannon on 12/28/21.
//

import XCTest

struct FilterCategoryScreen: Screen {
    
    let app: XCUIApplication
    
    // MARK: - Verifications
    func verifyShowingFilterCategoryScreen() {
        let filterNavigationBar = app.navigationBars["Filters"]
        XCTAssert(filterNavigationBar.exists)
    }
    
    // MARK: - Actions
    
}
