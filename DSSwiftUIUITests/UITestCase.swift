//
//  UITestCase.swift
//  DSSwiftUIUITests
//
//  Created by Matt Gannon on 12/28/21.
//
//  Page object pattern based on https://swiftwithmajid.com/2021/03/24/ui-testing-using-page-object-pattern-in-swift/

import XCTest

class UITestCase: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication.testable()
        //app.launchArguments = ["testing"]
        app.launch()
    }
    
    override func tearDown() {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .deleteOnSuccess
        add(attachment)
        app.terminate()
        super.tearDown()
    }
    
}

extension XCUIApplication {
    
    static func testable() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment.updateValue("YES", forKey: "UITesting")
        return app
    }
    
}

extension XCUIElementQuery {
    
    func testIdentifier(_ identifier: UITestIdentifier) -> XCUIElement {
        return self[identifier.identifierString]
    }
    
}
