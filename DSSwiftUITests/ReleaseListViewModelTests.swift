//
//  ReleaseListViewModelTests.swift
//  DSSwiftUITests
//
//  Created by Matt Gannon on 12/13/21.
//

import XCTest
@testable import DSSwiftUI

class ReleaseListViewModelTests: XCTestCase {

    var sut: ReleaseListViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.sut = try ReleaseListViewModel.getTestable()
    }

    override func tearDownWithError() throws {
        self.sut = nil
        try super.tearDownWithError()
    }
    
    func testGetTestable() throws {
        let testable: ReleaseListViewModel = try ReleaseListViewModel.getTestable()
        XCTAssertFalse(testable.releases.isEmpty)
    }
    
    func testSetSelectedRelease() throws {
        guard let releaseToSelect: ReleaseViewModel = sut.releases.first else {
            throw TestingError.runtimeError("Unable to set releaseToSelect")
        }
        
        sut.setSelectedRelease(releaseToSelect)
        XCTAssertEqual(releaseToSelect, sut.selectedRelease)
    }
    
    func testPickRandomRelease() throws {
        sut.pickRandomRelease()
        XCTAssertNotNil(sut.selectedRelease)
    }
    
    func testRemoveRandomRelease() throws {
        sut.pickRandomRelease()
        sut.removeRandomeRelease()
        XCTAssertNil(sut.selectedRelease)
    }
    
    func testClearSearch() throws {
        sut.searchQuery = "query"
        sut.filterController.tappedOption(sut.filterController.getFirstFilterOption())
        sut.clearSearchAndFilter()
        XCTAssertTrue(sut.searchQuery.isEmpty)
    }
    
    func testSetSortedReleases() throws {
        sut.setSortedReleases(sut.releases)
        for index in 0..<(sut.releases.count-1) {
            let firstArtist = sut.releases[index].firstArtist
            let secondArtist = sut.releases[index+1].firstArtist
            XCTAssertTrue(firstArtist <= secondArtist)
        }
    }
}

internal enum TestingError: Error {
    case runtimeError(String)
}

extension ReleaseListViewModel {
    
    static func getTestable() throws -> ReleaseListViewModel {
        if let path = Bundle.main.url(forResource: "ShortResponse", withExtension: "json") {
            let data = try Data(contentsOf: path, options: .dataReadingMapped)
            let model = try JSONDecoder().decode(CollectionReleasesResponse.self,
                                                 from: data)
            let releases: [ReleaseViewModel] = model.releases.map { ReleaseViewModel(from: $0) }
            let viewModel: ReleaseListViewModel = ReleaseListViewModel()
            viewModel.setReleases(releases)
            return viewModel
        } else {
            throw TestingError.runtimeError("Was unable to create a view model to test")
        }
    }
    
    func setReleases(_ releases: [ReleaseViewModel]) {
        self.setSortedReleases(releases)
        self.filterController.updateFilters(for: releases)
    }
    
}
