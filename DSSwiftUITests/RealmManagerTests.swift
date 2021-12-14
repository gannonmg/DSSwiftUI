//
//  RealmManagerTests.swift
//  DSSwiftUITests
//
//  Created by Matt Gannon on 12/13/21.
//

import XCTest
@testable import DSSwiftUI

class RealmManagerTests: XCTestCase {
    
    var releaseModels: [DCReleaseModel]!

    override func setUpWithError() throws {
        
        RealmManager.shared.deleteAllReleases()
        
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

    func testRealmSaving() throws {
        RealmManager.shared.add(releases: releaseModels)
        let stored = RealmManager.shared.getAllReleases()
        XCTAssertNotNil(stored)
        XCTAssertFalse(stored!.isEmpty)
    }
    
    func testRealmDelete() throws {
        RealmManager.shared.add(releases: releaseModels)
        RealmManager.shared.deleteAllReleases()
        let stored = RealmManager.shared.getAllReleases()
        XCTAssertTrue(stored == [])
    }


}
