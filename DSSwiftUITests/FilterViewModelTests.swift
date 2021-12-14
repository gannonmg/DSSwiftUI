//
//  FilterViewModelTests.swift
//  DSSwiftUITests
//
//  Created by Matt Gannon on 12/13/21.
//

import XCTest
@testable import DSSwiftUI

class FilterViewModelTests: XCTestCase {

    var filterVM: FilterViewModel!
    var releaseVMs: [ReleaseViewModel]!

    override func setUpWithError() throws {
        if let path = Bundle.main.url(forResource: "ShortResponse", withExtension: "json")
        {
            let data = try Data(contentsOf: path, options: .dataReadingMapped)
            let model = try JSONDecoder().decode(CollectionReleasesResponse.self,
                                                 from: data)
            let releaseVMs = model.releases.map { ReleaseViewModel(from: $0) }
            XCTAssertFalse(releaseVMs.isEmpty)
            self.releaseVMs = releaseVMs
            filterVM = FilterViewModel(releases: releaseVMs)
        }
    }

    override func tearDownWithError() throws {
        filterVM = nil
        releaseVMs = nil
    }

    func testFilterBuilding() throws {
        XCTAssertNotNil(filterVM.filterOptions[.genres])
        XCTAssertNotNil(filterVM.filterOptions[.styles])
        XCTAssertNotNil(filterVM.filterOptions[.formats])
        XCTAssertNotNil(filterVM.filterOptions[.descriptions])
        
        XCTAssertFalse(filterVM.filterOptions[.genres]!.isEmpty)
        XCTAssertFalse(filterVM.filterOptions[.styles]!.isEmpty)
        XCTAssertFalse(filterVM.filterOptions[.formats]!.isEmpty)
        XCTAssertFalse(filterVM.filterOptions[.descriptions]!.isEmpty)
    }
    
    func testToggleFilter() throws {
        let optionToToggle = filterVM.firstFilterOption()
        XCTAssertFalse(optionToToggle.selected)
        filterVM.tappedOption(optionToToggle)
        let toggledOption = filterVM.firstFilterOption()
        XCTAssertTrue(toggledOption.selected)
    }
    
    func testRemoveFilter() throws {
        let optionToToggle = filterVM.firstFilterOption()
        filterVM.tappedOption(optionToToggle)
        filterVM.removeOption(optionToToggle)
        let removedOption = filterVM.firstFilterOption()
        XCTAssertFalse(removedOption.selected)
    }
    
    func testRemoveAllFilters() throws {
        for key in FilterCategory.allCases {
            filterVM.filterOptions[key]?.forEach { filterVM.tappedOption($0) }
        }
        
        XCTAssertFalse(filterVM.selectedFilters.isEmpty)
        filterVM.turnOffAllFilters()
        XCTAssertTrue(filterVM.selectedFilters.isEmpty)
    }
    
    func testMigration() throws {
        let optionToTrack = filterVM.firstFilterOption()
        XCTAssertFalse(filterVM.firstFilterOption().selected)
        filterVM.tappedOption(optionToTrack)
        XCTAssertTrue(filterVM.firstFilterOption().selected)
        filterVM.updateFilters(for: releaseVMs)
        XCTAssertTrue(filterVM.firstFilterOption().selected)
    }
    
    func testCategoryGetters() throws {
        XCTAssertEqual(filterVM.filterOptions[.genres]!.map{ $0.title },
                       ["Electronic", "Funk / Soul", "Hip Hop", "Pop", "Rock"])
        XCTAssertEqual(filterVM.filterOptions[.styles]!.map{ $0.title },
                       ["Alternative Rock", "Conscious", "Folk Rock", "Indie Pop", "Indie Rock", "Jazzy Hip-Hop", "Neo Soul", "RnB/Swing"])
        XCTAssertEqual(filterVM.filterOptions[.formats]!.map{ $0.title },
                       ["All Media", "Cassette", "Vinyl"])
        XCTAssertEqual(filterVM.filterOptions[.descriptions]!.map{ $0.title },
                       ["Album", "LP", "Limited Edition", "Numbered", "Reissue", "Repress", "Stereo"])
    }
    
    func testExclusivePredicate() throws {
        filterVM.tappedOption(filterVM.filterOptions[.styles]![0])
        filterVM.tappedOption(filterVM.filterOptions[.styles]![1])
        XCTAssertEqual(filterVM.predicate,
                       NSPredicate(format: "ANY basicInformation.styles CONTAINS[dc] 'Alternative Rock' AND ANY basicInformation.styles CONTAINS[dc] 'Conscious'"))
    }
    
    func testInclusivePredicate() throws {
        filterVM.tappedOption(filterVM.filterOptions[.styles]![0])
        filterVM.tappedOption(filterVM.filterOptions[.styles]![1])
        filterVM.exclusiveFilter = false
        XCTAssertEqual(filterVM.predicate,
                       NSPredicate(format: "ANY basicInformation.styles CONTAINS[dc] 'Alternative Rock' OR ANY basicInformation.styles CONTAINS[dc] 'Conscious'"))
    }
    
}

private extension FilterViewModel {
    
    func firstFilterOption() -> FilterOption {
        return filterOptions[.styles]!.first!
    }
    
}
