//
//  FilterViewModelTests.swift
//  DSSwiftUITests
//
//  Created by Matt Gannon on 12/13/21.
//

import XCTest
@testable import DSSwiftUI

class FilterViewModelTests: XCTestCase {

    var sut: FilterViewModel!
    var releaseVMs: [ReleaseViewModel]!

    override func setUpWithError() throws {
        try super.setUpWithError()
        if let path = Bundle.main.url(forResource: "ShortResponse", withExtension: "json") {
            let data = try Data(contentsOf: path, options: .dataReadingMapped)
            let model = try JSONDecoder().decode(CollectionReleasesResponse.self,
                                                 from: data)
            let releaseVMs = model.releases.map { ReleaseViewModel(from: $0) }
            XCTAssertFalse(releaseVMs.isEmpty)
            self.releaseVMs = releaseVMs
            self.sut = FilterViewModel(releases: releaseVMs)
        } else {
            
        }
    }

    override func tearDownWithError() throws {
        sut = nil
        releaseVMs = nil
        try super.tearDownWithError()
    }

    func testFilterBuilding() throws {
        XCTAssertNotNil(sut.filterOptions[.genres])
        XCTAssertNotNil(sut.filterOptions[.styles])
        XCTAssertNotNil(sut.filterOptions[.formats])
        XCTAssertNotNil(sut.filterOptions[.descriptions])
        
        XCTAssertFalse(sut.filterOptions[.genres]!.isEmpty)
        XCTAssertFalse(sut.filterOptions[.styles]!.isEmpty)
        XCTAssertFalse(sut.filterOptions[.formats]!.isEmpty)
        XCTAssertFalse(sut.filterOptions[.descriptions]!.isEmpty)
    }
    
    func testToggleFilter() throws {
        let optionToToggle = sut.getFirstFilterOption()
        XCTAssertFalse(optionToToggle.selected)
        sut.tappedOption(optionToToggle)
        let toggledOption = sut.getFirstFilterOption()
        XCTAssertTrue(toggledOption.selected)
    }
    
    func testRemoveFilter() throws {
        let optionToToggle = sut.getFirstFilterOption()
        sut.tappedOption(optionToToggle)
        sut.removeOption(optionToToggle)
        let removedOption = sut.getFirstFilterOption()
        XCTAssertFalse(removedOption.selected)
    }
    
    func testRemoveAllFilters() throws {
        for key in FilterCategory.allCases {
            sut.filterOptions[key]?.forEach { sut.tappedOption($0) }
        }
        
        XCTAssertFalse(sut.selectedFilters.isEmpty)
        sut.turnOffAllFilters()
        XCTAssertTrue(sut.selectedFilters.isEmpty)
    }
    
    func testMigration() throws {
        let optionToTrack = sut.getFirstFilterOption()
        XCTAssertFalse(sut.getFirstFilterOption().selected)
        sut.tappedOption(optionToTrack)
        XCTAssertTrue(sut.getFirstFilterOption().selected)
        sut.updateFilters(for: releaseVMs)
        XCTAssertTrue(sut.getFirstFilterOption().selected)
    }
    
    func testCategoryGetters() throws {
        XCTAssertEqual(sut.filterOptions[.genres]!.map { $0.title },
                       ["Electronic", "Funk / Soul", "Hip Hop", "Pop", "Rock"])
        XCTAssertEqual(sut.filterOptions[.styles]!.map { $0.title },
                       ["Alternative Rock", "Conscious", "Folk Rock", "Indie Pop", "Indie Rock", "Jazzy Hip-Hop", "Neo Soul", "RnB/Swing"])
        XCTAssertEqual(sut.filterOptions[.formats]!.map { $0.title },
                       ["All Media", "Cassette", "Vinyl"])
        XCTAssertEqual(sut.filterOptions[.descriptions]!.map { $0.title },
                       ["Album", "LP", "Limited Edition", "Numbered", "Reissue", "Repress", "Stereo"])
    }
    
    func testExclusivePredicate() throws {
        sut.tappedOption(sut.filterOptions[.styles]![0])
        sut.tappedOption(sut.filterOptions[.styles]![1])
        let format: String = "ANY basicInformation.styles CONTAINS[dc] 'Alternative Rock' AND ANY basicInformation.styles CONTAINS[dc] 'Conscious'"
        XCTAssertEqual(sut.predicate,
                       NSPredicate(format: format))
    }
    
    func testInclusivePredicate() throws {
        sut.tappedOption(sut.filterOptions[.styles]![0])
        sut.tappedOption(sut.filterOptions[.styles]![1])
        sut.exclusiveFilter = false
        let format: String = "ANY basicInformation.styles CONTAINS[dc] 'Alternative Rock' OR ANY basicInformation.styles CONTAINS[dc] 'Conscious'"
        XCTAssertEqual(sut.predicate,
                       NSPredicate(format: format))
    }
    
    func testGetFirstFilterOption() throws {
        let option: FilterOption = sut.getFirstFilterOption()
        XCTAssertEqual(option.title, "Alternative Rock")
    }
    
}

internal extension FilterViewModel {
    
    func getFirstFilterOption() -> FilterOption {
        return filterOptions[.styles]!.first!
    }
    
}
