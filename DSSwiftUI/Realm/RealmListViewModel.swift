//
//  RealmListViewModel.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/9/21.
//

import Combine
import RealmSwift

class RealmListViewModel: ObservableObject {
    
    @ObservedResults(RealmReleaseCodable.self) private var releasesResults
    @Published private(set) var releases:[RealmReleaseCodable] = []
    
    @Published var randomizedRelease: RealmReleaseCodable?
    @Published var showingFilters: Bool = false
    @Published var searchQuery: String = ""
    
    private(set) var filterController = RealmFilterController(releases: [])
    
    private var resultsCancellable: AnyCancellable?
    
    init() {
        self.resultsCancellable = releasesResults
            .collectionPublisher
            .assertNoFailure()
            .sink { releaseResults in
                #warning("TODO: Migrate filter controller to new set of filters instead of new object")
                let releases = Array(releaseResults)
                self.releases = releases
                self.filterController = RealmFilterController(releases: releases)
            }
    }
    
    deinit {
        resultsCancellable?.cancel()
        resultsCancellable = nil
    }
    
    func getReleases() {
        DCManager.shared.getAllReleasesForUser { releases in
            RealmManager.shared.update(with: releases)
        }
    }
    
    func pickRandomRelease() {
//        let predicate = viewModel.filterController.predicate
//        let releases = (predicate == nil) ? releases : releases.filter(predicate!)
        randomizedRelease = releases.randomElement()
    }
    
}
