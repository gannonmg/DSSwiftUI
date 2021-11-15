//
//  ReleaseCollectionViewModel.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 9/3/21.
//

import SwiftUI
import Combine

class ReleaseCollectionViewModel: ObservableObject {
    
    @Published var releases:[ReleaseViewModel] {
        didSet {
            filterController.unfilteredReleases = releases
        }
    }
    
    @ObservedObject var filterController: FilterController
    @Published var showingFilters: Bool = false
    @Published var selected: ReleaseViewModel? = nil
    var filterCancellable:AnyCancellable?
    
    //MARK: Init
    init() {
        self.releases = []
        self.filterController = FilterController(releases: [])
        
        //Pass along changes from the filter controller
        filterCancellable = filterController.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }
    
    func getReleases() {
//        DCManager.shared.getAllReleasesForUser(forceRefresh: true) { releases in
//            if releases.isEmpty {
//                print("Releases was empty")
//            } else {
//                print("Got \(releases.count) releases")
//                self.releases = releases
//            }
//        }
    }
    
}
