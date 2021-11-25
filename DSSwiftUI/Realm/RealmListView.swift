//
//  RealmListView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/10/21.
//

import Combine
import RealmSwift
import SwiftUI

class RealmListViewModel: ObservableObject {
    
    @Published var showingFilters: Bool = false
    private(set) var filterController = RealmFilterController(releases: [])
    private var cancellable: AnyCancellable?
    
    func setCancellable(with results: Results<RealmReleaseCodable>) {
//        self.cancellable = results
//            .collectionPublisher
//            .assertNoFailure()
//            .sink { releaseResults in
//                print("Releases changed")
//                let releases = Array(releaseResults)
//                self.filterController = RealmFilterController(releases: releases)
//            }
    }
    
    deinit {
        cancellable?.cancel()
        cancellable = nil
    }
    
}

struct RealmListView: View {
    
    @ObservedResults(RealmReleaseCodable.self) var releases
    @StateObject var viewModel = RealmListViewModel()
    
    var body: some View {
        NavigationView {
            conditionalView
                .navigationTitle("Collection")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button("Log Out", role: .destructive,
                                   action: AppViewModel.shared.logOut)
                            Button("Delete Collection", role: .destructive,
                                   action: RealmManager.shared.deleteAllReleases)
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Filter") {
                            viewModel.showingFilters = true
                        }
                    }
                }
        }
        .onAppear {
            viewModel.setCancellable(with: releases)
        }
//        .sheet(isPresented: $viewModel.showingFilters) {
//            FilterView(filterController: viewModel.filterController)
//        }
    }
    
    var conditionalView: some View {
        if releases.isEmpty {
            return AnyView(Button("Get Releases", action: getReleases))
        } else {
            return AnyView(SwiftUI.List {
//                let predicate = NSPredicate(format: "ANY basicInformation.artists.name CONTAINS[dc] %@", "bad snacks")
//                let releases = releases.filter(predicate)
                ForEach(releases) { release in
                    Text(release.basicInformation.title)
                }
            })
        }
    }
    
    func getReleases() {
        DCManager.shared.getAllReleasesForUser { releases in
            RealmManager.shared.update(with: releases)
        }
    }

}
