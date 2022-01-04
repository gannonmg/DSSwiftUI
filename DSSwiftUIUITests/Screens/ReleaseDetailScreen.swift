//
//  ReleaseDetailScreen.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/28/21.
//

import XCTest

struct ReleaseDetailScreen: Screen {
    
    let app: XCUIApplication
    
    // MARK: - Verifications
    func verifyScrobbleButtonShowing() {
        let scrobbleButtonExists = app.buttons[ReleaseDetailIdentifier.scrobbleButton].exists
        XCTAssert(scrobbleButtonExists)
    }
    
    func verifyScrobbleButtonHidden() {
        let scrobbleButtonExists = app.buttons[ReleaseDetailIdentifier.scrobbleButton].exists
        XCTAssertFalse(scrobbleButtonExists)
    }
    
}
