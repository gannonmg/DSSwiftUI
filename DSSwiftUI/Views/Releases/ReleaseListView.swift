//
//  ReleaseListView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/4/21.
//

import SwiftUI
import Combine

class ReleaseListViewModel: ObservableObject {
    
    @Published var selectedRelease:ReleaseViewModel? = nil
    @Published var releases:[ReleaseViewModel] {
        didSet {
            filterController.unfilteredReleases = releases
        }
    }
    
    @ObservedObject var filterController: FilterController
    var filterCancellable:AnyCancellable?
    
    //MARK: Init
    init() {
        let releases = CoreDataManager.shared.fetchCollection() ?? []
        self.releases = releases
        self.filterController = FilterController(releases: releases)
        
        //Pass along changes from the filter controller
        filterCancellable = filterController.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }
    
    func getReleases() {
        DCManager.shared.getAllReleasesForUser(forceRefresh: true) { releases in
            if releases.isEmpty {
                print("Releases was empty")
            } else {
                print("Got \(releases.count) releases")
                self.releases = releases
            }
        }
    }
    
}


struct ReleaseListView: View {
    
    @StateObject private var releaseListViewModel:ReleaseListViewModel = .init()
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 0) {
                        RefreshControl(coordinateSpace: .named("RefreshControl"),
                                       onRefresh: onRefresh)
                        
                        if releaseListViewModel.releases.isEmpty {
                            Button("Get releases") {
                                releaseListViewModel.getReleases()
                            }
                        } else {
                            releaseList
                        }
                    }
                }

//                if let release = releaseListViewModel.selectedRelease {
//                    ReleaseDetailView(release: release) {
//                        releaseListViewModel.selectedRelease = nil
//                    }
//                }
            }
            .coordinateSpace(name: "RefreshControl")
            .navigationTitle("Releases")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.backgroundColor)
        }
        .sheet(isPresented: $showingFilters) {
            FilterView(filterController: releaseListViewModel.filterController)
        }
        .sheet(item: $releaseListViewModel.selectedRelease) { release in
            ReleaseDetailView(release: release)
        }
    }
    
    var releaseList: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            Section(header: searchBar) {
                let filtered = releaseListViewModel.filterController.filteredReleases
                    .sorted(by: { $0.artist < $1.artist })
                ForEach(filtered, id: \.uuid) { release in
                    ReleaseItemView(release: release)
                        .onTapGesture {
                            releaseListViewModel.selectedRelease = release
                        }
                }
            }
        }
        .padding(.all, 0)
    }
    
    var searchBar: some View {
        VStack(spacing: 0) {
            HStack {
                let count = releaseListViewModel.releases.count
                let string = "\(count) Release\(count == 1 ? "" : "s")"
                TextField("Search \(string)", text: releaseListViewModel.$filterController.searchQuery)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                let filterCount = releaseListViewModel.filterController.selectedFilters.count
                let filterString = filterCount == 0 ? "Filters" : "Filters (\(filterCount))"
                Button(filterString) {
                    self.showingFilters = true
                }
                .padding(.trailing, 12)
            }
            .background(Color.backgroundColor
                            .opacity(0.95))
            .height(52)
            
            Color.separator
                .height(1)
        }
    }
    
    func onRefresh() {
        releaseListViewModel.getReleases()
    }
    
}

struct ReleaseItemView: View {
    
    let release:ReleaseViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                RemoteImageView(url: release.imageUrl,
                                placeholder: UIImage(systemName: "music.note.list")!)
                    .height(68)
                    .width(68)
                
                VStack(alignment: .leading) {
                    Text(release.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    Text(release.artistList)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
            }
            .padding()
            
            Color.separator
                .height(1)
        }
    }
    
}

struct ReleaseDetailView: View {
    
    @ObservedObject private(set) var release:ReleaseViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                RemoteImageView(url: release.imageUrl,
                                placeholder: UIImage(systemName: "music.note.list")!)
                Text(release.title)
                    .font(.headline)
                    .foregroundColor(.pink)
                Text(release.artistList)
                    .font(.subheadline)
                    .foregroundColor(.pink)
                
                if let tracks = release.tracks {
                    ForEach(tracks, id: \.self) {
                        Text($0.displayText)
                            .foregroundColor(.pink)
                    }
                }
            }
        }
        .onAppear {
            release.getDetail()
        }
        
    }
    
}

struct ReleaseListView_Previews: PreviewProvider {
    static var previews: some View {
        ReleaseListView()
    }
}
