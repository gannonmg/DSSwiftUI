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
        guard let path: URL = Bundle.main.url(forResource: "SingleRelease", withExtension: "json") else {
            throw URLError(.badURL)
        }
        
        let data: Data = try Data(contentsOf: path, options: .dataReadingMapped)
        let model: DCReleaseModel = try JSONDecoder().decode(DCReleaseModel.self,
                                                             from: data)
        
        sut = ReleaseViewModel(from: model)
    }

    func testArtistList() throws {
        XCTAssertEqual(sut.artistList, "The War On Drugs, Fakey McFakename")
    }
    
    func testFirstArtist() throws {
        XCTAssertEqual(sut.firstArtist, "The War On Drugs")
    }

}
