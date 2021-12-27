//
//  UITestHelpers.swift
//  DSSwiftUIUITests
//
//  Created by Matt Gannon on 12/27/21.
//

import XCTest

extension XCUIApplication {
    
    static func testable() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment.updateValue("YES", forKey: "UITesting")
        return app
    }
    
}
