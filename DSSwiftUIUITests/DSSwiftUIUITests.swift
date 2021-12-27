//
//  DSSwiftUIUITests.swift
//  DSSwiftUIUITests
//
//  Created by Matt Gannon on 12/16/21.
//

import XCTest

class DSSwiftUIUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        self.app = XCUIApplication.testable()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        app.buttons["Log In"].tap()
    }

}
