//
//  SmartSearchTests.swift
//  DSSwiftUITests
//
//  Created by Matt Gannon on 12/13/21.
//

import XCTest
@testable import DSSwiftUI

class SmartSearchTests: XCTestCase {

    let contentToSearch = ["This is a sentence",
                           "This next one is gibberish",
                           "dsaufhdpaf awiundhfiud syfui duafug a"]

    func testMatch() throws {
        let query = "This is "
        let matcher = SmartSearchMatcher(searchString: query)
        let matches = contentToSearch.filter { matcher.matches($0) }
        XCTAssertEqual(matches.count, 2)
    }
    
    func testMixedMatch() throws {
        let query = "is This "
        let matcher = SmartSearchMatcher(searchString: query)
        let matches = contentToSearch.filter { matcher.matches($0) }
        XCTAssertEqual(matches.count, 2)
    }
    
    func testMixedMatchCaseIrrelevent() throws {
        let query = "is this "
        let matcher = SmartSearchMatcher(searchString: query)
        let matches = contentToSearch.filter { matcher.matches($0) }
        XCTAssertEqual(matches.count, 2)
    }
    
    func testNoMatch() throws {
        let query = "asdfghjkg "
        let matcher = SmartSearchMatcher(searchString: query)
        let matches = contentToSearch.filter { matcher.matches($0) }
        XCTAssertEqual(matches.count, 0)
    }

}
