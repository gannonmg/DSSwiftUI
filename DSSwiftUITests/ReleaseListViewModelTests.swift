//
//  ReleaseListViewModelTests.swift
//  DSSwiftUITests
//
//  Created by Matt Gannon on 12/13/21.
//

import XCTest
@testable import DSSwiftUI

class ReleaseListViewModelTests: XCTestCase {

    var releaseModels: [DCReleaseModel]!
    
    override func setUpWithError() throws {
        if let path = Bundle.main.url(forResource: "ShortResponse", withExtension: "json")
        {
            let data = try Data(contentsOf: path, options: .dataReadingMapped)
            let model = try JSONDecoder().decode(CollectionReleasesResponse.self,
                                                 from: data)
            releaseModels = model.releases
            XCTAssertFalse(releaseModels.isEmpty)

        }
    }

    override func tearDownWithError() throws {
        releaseModels = nil
    }

    func testRealmChangesOnViewModel() throws {
        RealmManager.shared.deleteAllReleases()
        let hopefullyEmptyReleases = RealmManager.shared.getAllReleases() ?? []
        XCTAssertTrue(hopefullyEmptyReleases.isEmpty)
        
        let viewModel = ReleaseListViewModel()
        XCTAssertTrue(viewModel.releases.isEmpty)
        RealmManager.shared.add(releases: releaseModels)
        
        let expectation = expectation(description: "Give time for publisher from Realm")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(viewModel.releases.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFilter() throws {
        RealmManager.shared.add(releases: releaseModels)
        let viewModel = ReleaseListViewModel()
        viewModel.filterController.tappedOption(FilterOption(title: "Indie Rock"))
        
    }

}
