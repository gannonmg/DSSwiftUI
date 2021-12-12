//
//  RealmListViewModel.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/9/21.
//

import Combine
import RealmSwift
import Foundation

class RealmListViewModel: ObservableObject {
    
    @ObservedResults(RealmReleaseCodable.self) private var releasesResults
    @Published private(set) var releases:[ReleaseViewModel] = []
    
    @Published private(set) var selectedRelease: ReleaseViewModel?
    @Published var showingFilters: Bool = false
    @Published var searchQuery: String = "" {
        didSet { searchChanged() }
    }
    
    private(set) var filterController = RealmFilterController(releases: [])
    
    var trulyEmpty: Bool {
        return releasesResults.freeze().isEmpty
    }
    
    private var resultsCancellable: AnyCancellable?
    private var filterCancellable: AnyCancellable?
    
    init() {
        self.resultsCancellable = releasesResults
            .collectionPublisher
            .assertNoFailure()
            .sink { releaseResults in
                self.handleNewResults(releaseResults)
            }
        
        self.filterCancellable = filterController.$predicate
            .sink { predicate in
                self.filterUpdated(predicate: predicate)
            }
    }
    
    deinit {
        resultsCancellable?.cancel()
        resultsCancellable = nil
        filterCancellable?.cancel()
        filterCancellable = nil
    }
    
    func handleNewResults(_ results: Results<RealmReleaseCodable>) {
        let releases = Array(results).map { ReleaseViewModel(from: $0) }
        self.releases = releases
        self.filterController.updateFilters(for: releases)
    }
    
    func getReleases() {
        DCManager.shared.getAllReleasesForUser { releases in
            RealmManager.shared.update(with: releases)
        }
    }
    
    func setSelectedRelease(_ release: ReleaseViewModel) {
        selectedRelease = release
    }
    
    func pickRandomRelease() {
        selectedRelease = releases.randomElement()
    }
    
    func removeRandomeRelease() {
        selectedRelease = nil
    }
    
    func searchChanged() {
        filterUpdated(predicate: filterController.predicate)
    }
    
    func filterUpdated(predicate: NSPredicate?) {
        var releases:[ReleaseViewModel] = []
        
        if let predicate = predicate {
            let results = self.releasesResults.filter(predicate)
            releases = Array(results).map { ReleaseViewModel(from: $0) }
        } else {
            releases = Array(releasesResults).map { ReleaseViewModel(from: $0) }
        }
        
        let smartSearch = SmartSearchMatcher(searchString: searchQuery)
        releases = releases.filter { release in
            let filterableTitle = release.title + " " + (release.artists.map { $0 }.first?.name ?? "")
            return smartSearch.matches(filterableTitle)
        }
        
        self.releases = releases
    }
    
}
