//
//  ReleaseViewModelTests.swift
//  DSSwiftUITests
//
//  Created by Matt Gannon on 12/13/21.
//

import XCTest
@testable import DSSwiftUI

class ReleaseViewModelTests: XCTestCase {
    
    var viewModel: ReleaseViewModel!
    
    override func setUpWithError() throws {
        if let path = Bundle.main.url(forResource: "SingleRelease", withExtension: "json")
        {
            let data = try Data(contentsOf: path, options: .dataReadingMapped)
            let model = try JSONDecoder().decode(DCReleaseModel.self,
                                                 from: data)
            viewModel = ReleaseViewModel(from: model)
        }
    }

    func testArtistList() throws {
        XCTAssertEqual(viewModel.artistList, "The War On Drugs, Fakey McFakename")
    }
    
    func testFirstArtist() throws {
        XCTAssertEqual(viewModel.firstArtist, "The War On Drugs")
    }

}
