//
//  ReleaseListView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/4/21.
//

import SwiftUI
import Combine

class ReleaseListViewModel: ObservableObject {
    
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
    
    @Namespace private var namespace
    @StateObject private var releaseListViewModel: ReleaseListViewModel = .init()
    
    var body: some View {
        NavigationView {
            if let selected = releaseListViewModel.selected {
                ReleaseDetailView(namespace: namespace,
                                  release: selected,
                                  onClose: { releaseListViewModel.selected = nil })
            } else {
                CollectionView(releaseListViewModel: releaseListViewModel,
                               namespace: namespace,
                               tappedRelease: tappedRelease(_:))
            }
        }
        .sheet(isPresented: $releaseListViewModel.showingFilters) {
            FilterView(filterController: releaseListViewModel.filterController)
        }
    }
    
    func tappedRelease(_ release: ReleaseViewModel) {
        withAnimation(.easeInOut) {
            releaseListViewModel.selected = release
        }
    }
    
}

struct CollectionView: View {
    
    @ObservedObject var releaseListViewModel: ReleaseListViewModel
    let namespace: Namespace.ID
    var tappedRelease: ((ReleaseViewModel)->Void)

//    @State private var showingGridView = true
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 0) {
                    RefreshControl(coordinateSpace: .named("RefreshControl"),
                                   onRefresh: onRefresh)
                    
                    if releaseListViewModel.releases.isEmpty {
                        Button("Get releases") {
                            releaseListViewModel.getReleases()
                        }
                    } else {
//                        if showingGridView {
//                            ReleaseGridView(releaseListViewModel: releaseListViewModel,
//                                            namespace: namespace,
//                                            tappedRelease: tappedRelease)
//                        } else {
                            CollectionListView(releaseListViewModel: releaseListViewModel,
                                               namespace: namespace,
                                               tappedRelease: tappedRelease)
//                        }
                    }
                }
            }
            
//            DisplayStyleButton(showingGridView: $showingGridView)
        }
        .coordinateSpace(name: "RefreshControl")
        .navigationTitle("Releases")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.backgroundColor)
    }
    
    private struct DisplayStyleButton: View {
        
        @Binding var showingGridView: Bool
        
        var body: some View {
            Button {
                withAnimation(.easeInOut) {
                    showingGridView.toggle()
                }
            } label: {
                Text("S")
                    .foregroundColor(.white)
                    .height(32)
                    .width(32)
                    .background(Color.blue.cornerRadius(16))
            }
            
        }
    }
    
    func onRefresh() {
        releaseListViewModel.getReleases()
    }
    
}

struct CollectionListView: View {
    
    @ObservedObject var releaseListViewModel: ReleaseListViewModel
    let namespace: Namespace.ID
    var tappedRelease: ((ReleaseViewModel)->Void)

    var body: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            let header = SearchBarView(releaseListViewModel: releaseListViewModel,
                                       showingFilters: $releaseListViewModel.showingFilters)
            Section(header: header) {
                let filtered = releaseListViewModel.filterController.filteredReleases
                    .sorted(by: { $0.artist < $1.artist })
                ForEach(filtered, id: \.uuid) { release in
                    ReleaseItemView(namespace: namespace, release: release)
                        .onTapGesture { tappedRelease(release) }
                }
            }
        }
        .padding(.all, 0)
    }
    
}

struct ReleaseGridView: View {
    
    @ObservedObject var releaseListViewModel: ReleaseListViewModel
    let namespace: Namespace.ID
    var tappedRelease: ((ReleaseViewModel)->Void)
    
    let columns:[GridItem] = Array(repeating: .init(spacing: 0), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0, pinnedViews: .sectionHeaders) {
            let header = SearchBarView(releaseListViewModel: releaseListViewModel,
                                       showingFilters: $releaseListViewModel.showingFilters)
            Section(header: header) {
                let filtered = releaseListViewModel.filterController.filteredReleases
                    .sorted(by: { $0.artist < $1.artist })
                ForEach(filtered, id: \.uuid) { release in
                    ReleaseGridItem(namespace: namespace, release: release)
                        .onTapGesture { tappedRelease(release) }
                }
            }
        }
    }
    
}

struct SearchBarView: View {
    
    @ObservedObject var releaseListViewModel: ReleaseListViewModel
    @Binding var showingFilters: Bool
    
    var body: some View {
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
                    showingFilters = true
                }
                .padding(.trailing, 12)
            }
            Color.separator.height(1)
        }
        .background(Color.backgroundColor
                        .opacity(0.99))
        //.height(52)
    }
    
}

struct ReleaseGridItem: View {
    
    let namespace:Namespace.ID
    let release:ReleaseViewModel
    
    var body: some View {
        RemoteImageView(url: release.imageUrl,
                        placeholder: UIImage(systemName: "music.note.list")!)
            .matchedGeometryEffect(id: release.geoImage, in: namespace)
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fill)
    }
    
}

struct ReleaseItemView: View {
    
    let namespace:Namespace.ID
    let release:ReleaseViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                RemoteImageView(url: release.imageUrl,
                                placeholder: UIImage(systemName: "music.note.list")!)
                    .matchedGeometryEffect(id: release.geoImage, in: namespace)
                    .height(68)
                    .width(68)
                
                VStack(alignment: .leading) {
                    Text(release.title)
                        .matchedGeometryEffect(id: release.geoTitle, in: namespace)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    Text(release.artistList)
                        .matchedGeometryEffect(id: release.geoArtist, in: namespace)
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
    
    let namespace: Namespace.ID
    @ObservedObject var release: ReleaseViewModel
    var onClose: StandardAction

    var tracks:[DCTrack] { release.tracks ?? [] }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                RemoteImageView(url: release.imageUrl,
                                placeholder: UIImage(systemName: "music.note.list")!)
                    .matchedGeometryEffect(id: release.geoImage, in: namespace)

                Text(release.title)
                    .matchedGeometryEffect(id: release.geoTitle, in: namespace)
                    .font(.headline)
                    .foregroundColor(.pink)
                Text(release.artistList)
                    .matchedGeometryEffect(id: release.geoArtist, in: namespace)
                    .font(.subheadline)
                    .foregroundColor(.pink)
                
                Button("Close", action: onClose)
                
                if let tracks = release.tracks {
                    ForEach(tracks, id: \.self) {
                        Text($0.displayText)
                            .foregroundColor(.pink)
                    }
                    .onChange(of: release.tracks) { value in
                        print("Value is \(String(describing: value))")
                    }
                }
            }
        }
        .navigationTitle("Releases")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.backgroundColor)
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
