//
//  ReleaseViewModelTests.swift
//  DSSwiftUITests
//
//  Created by Matt Gannon on 12/13/21.
//

import XCTest
@testable import DSSwiftUI

class ReleaseViewModelTests: XCTestCase {
    
    var sut: ReleaseViewModel!
    
    override func setUpWithError() throws {
        if let path = Bundle.main.url(forResource: "SingleRelease", withExtension: "json") {
            let data = try Data(contentsOf: path, options: .dataReadingMapped)
            let model = try JSONDecoder().decode(DCReleaseModel.self,
                                                 from: data)
            sut = ReleaseViewModel(from: model)
        }
    }

    func testArtistList() throws {
        XCTAssertEqual(sut.artistList, "The War On Drugs, Fakey McFakename")
    }
    
    func testFirstArtist() throws {
        XCTAssertEqual(sut.firstArtist, "The War On Drugs")
    }

}
