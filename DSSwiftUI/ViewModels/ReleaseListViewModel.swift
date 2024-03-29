//
//  RealmListViewModel.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/9/21.
//

import Combine
import RealmSwift
import Foundation

class ReleaseListViewModel: ObservableObject {
    
    @ObservedResults(DCReleaseModel.self) private var releasesResults: Results<DCReleaseModel>
    @Published private(set) var releases: [ReleaseViewModel] = []
    
    @Published var selectedRelease: ReleaseViewModel?
    @Published var showingFilters: Bool = false
    @Published var searchQuery: String = "" {
        didSet { searchChanged() }
    }
    
    private(set) var filterController: FilterViewModel = .init(releases: [])
    
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
    
    func handleNewResults(_ results: Results<DCReleaseModel>) {
        let releases: [ReleaseViewModel] = Array(results).map { .init(from: $0) }
        self.setSortedReleases(releases)
        self.filterController.updateFilters(for: releases)
    }
    
    func setSortedReleases(_ releases: [ReleaseViewModel]) {
        self.releases = releases.sorted(by: { $0.firstArtist < $1.firstArtist })
    }
    
    func getRemoteReleases() throws {
        Task {
            let releases: [DCReleaseModel] = try await RemoteClientManager.shared.getAllReleasesForUser(forceRefresh: false)
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
        var releases: [ReleaseViewModel] = []
        
        if let predicate: NSPredicate = predicate {
            let results: Results<DCReleaseModel> = self.releasesResults.filter(predicate)
            releases = Array(results).map { ReleaseViewModel(from: $0) }
        } else {
            releases = Array(releasesResults).map { ReleaseViewModel(from: $0) }
        }
        
        let smartSearch: SmartSearchMatcher = .init(searchString: searchQuery)
        releases = releases.filter { release in
            let artist: String = release.artists.first?.name ?? ""
            let filterableTitle: String = release.title + " " + artist
            return smartSearch.matches(filterableTitle)
        }
        
        self.setSortedReleases(releases)
    }
    
    func clearSearchAndFilter() {
        self.searchQuery = ""
        filterController.turnOffAllFilters()
    }
    
}
