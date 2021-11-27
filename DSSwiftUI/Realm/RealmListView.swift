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
    
    static let shared = RealmListViewModel()
    private init() {}
    
    @Published var randomizedRelease: RealmReleaseCodable?
    @Published var showingFilters: Bool = false
    private(set) var filterController = RealmFilterController(releases: [])
    private var cancellable: AnyCancellable?
    
    func setCancellable(with results: Results<RealmReleaseCodable>) {
        self.cancellable = results
            .collectionPublisher
            .assertNoFailure()
            .sink { releaseResults in
                #warning("TODO: Migrate filter controller to new set of filters instead of new object")
                let releases = Array(releaseResults)
                self.filterController = RealmFilterController(releases: releases)
            }
    }
    
    deinit {
        cancellable?.cancel()
        cancellable = nil
    }
    
    func getReleases() {
        DCManager.shared.getAllReleasesForUser { releases in
            RealmManager.shared.update(with: releases)
        }
    }
    
}

struct RealmListView: View {
    
    @ObservedResults(RealmReleaseCodable.self) var releases
    @ObservedObject var viewModel = RealmListViewModel.shared
    
    init() {
        viewModel.setCancellable(with: releases)
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                conditionalView
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        leadingItem
                        shuffleItem
                        ToolbarItem(placement: .principal, content: { Text("Collection") })
                        trailingItem
                    }
            }
            
            if let randomizedRelease = viewModel.randomizedRelease {
                SelectedReleaseView(release: randomizedRelease)
            }
        }
        .sheet(isPresented: $viewModel.showingFilters) {
            FilterView(filterController: viewModel.filterController)
        }
    }
    
    var conditionalView: some View {
        if releases.isEmpty {
            return AnyView(Button("Get Releases", action: viewModel.getReleases)
                            .buttonStyle(.bordered))
        } else {
            return AnyView(listView)
        }
    }
    
    var listView: some View {
        SwiftUI.List {
            let predicate = viewModel.filterController.predicate
            let releases = (predicate == nil) ? releases : releases.filter(predicate!)
            ForEach(releases) { release in
                VStack(alignment: .leading) {
                    Text(release.basicInformation.title)
                    Text(release.basicInformation.artists.first!.name)
                        .font(.callout)
                    Text("Genres: " + release.basicInformation.genres.map { $0 }.joined(separator: ", "))
                        .font(.caption)
                    Text("Styles: " + release.basicInformation.styles.map { $0 }.joined(separator: ", "))
                        .font(.caption)
                    
                    let formats = release.basicInformation.formats.map { $0 }
                    Text("Formats: " + formats.map { $0.name }.joined(separator: ", "))
                        .font(.caption)
                    
                    let descriptions = formats.map { $0.descriptions }.flatMap { $0 }.uniques
                    Text("Descriptions: " + descriptions.joined(separator: ", "))
                        .font(.caption)
                }
            }
        }
    }
    
    var leadingItem: some ToolbarContent {
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
    }
    
    var shuffleItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                pickRandomRelease()
            } label: {
                Image(systemName: "shuffle")
            }

        }
    }
    
    var trailingItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Filter") {
                viewModel.showingFilters = true
            }
        }
    }
    
    func pickRandomRelease() {
        let predicate = viewModel.filterController.predicate
        let releases = (predicate == nil) ? releases : releases.filter(predicate!)
        viewModel.randomizedRelease = releases.randomElement()
    }

}

struct SelectedReleaseView: View {
    
    let release: RealmReleaseCodable
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
            HStack(spacing:8) {
                ZStack(alignment: .topLeading) {
                    RemoteImageView(url: URL(string: release.basicInformation.coverImage),
                                    placeholder: UIImage(systemName: "photo")!)
                    Button {
                        RealmListViewModel.shared.randomizedRelease = nil
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundColor(.white)
                            .height(20)
                            .width(20)
                            .background { Color.black }
                            .padding(.top, 8)
                            .padding(.leading, 8)
                    }

                }
                VStack(alignment: .leading) {
                    Text(release.basicInformation.title)
                    Text(release.basicInformation.artists.first!.name)
                        .font(.callout)
                }
            }
            .background { Color.white }
            .cornerRadius(20)
            .padding(.horizontal, 20)
        }
    }
    
}
