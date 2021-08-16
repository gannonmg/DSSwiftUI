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
                    RefreshControl(coordinateSpace: .named("RefreshControl"),
                                   onRefresh: onRefresh)
                    
                    if releaseListViewModel.releases.isEmpty {
                        Button("Get releases") {
                            releaseListViewModel.getReleases()
                        }
                    } else {
                        LazyVStack(pinnedViews: .sectionHeaders) {
                            Section(header: searchBar) {
                                let filtered = releaseListViewModel.filterController.filteredReleases
                                ForEach(filtered, id: \.uuid) { release in
                                    ReleaseItemView(release: release)
                                        .onTapGesture {
                                            releaseListViewModel.selectedRelease = release
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
                
                if let release = releaseListViewModel.selectedRelease {
                    ReleaseDetailView(release: release) {
                        releaseListViewModel.selectedRelease = nil
                    }
                }
                
            }
            .coordinateSpace(name: "RefreshControl")
            .navigationTitle("Releases")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingFilters) {
            FilterView(filterController: releaseListViewModel.filterController)
        }
    }
    
    var searchBar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.gray)
                .height(48)

            HStack {
                let count = releaseListViewModel.releases.count
                let string = "\(count) Release\(count == 1 ? "" : "s")"
                TextField("Search \(string)", text: releaseListViewModel.$filterController.searchQuery)
                    .padding()
                
                let filterCount = releaseListViewModel.filterController.selectedFilters.count
                let filterString = filterCount == 0 ? "Filters" : "Filters (\(filterCount))"
                Button(filterString) {
                    self.showingFilters = true
                }
                .padding(.trailing, 12)
            }
        }
    }
    
    func onRefresh() {
        releaseListViewModel.getReleases()
    }
    
}

struct ReleaseItemView: View {
    
    let release:ReleaseViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.white)
                .standardShadow()
            
            HStack(alignment: .top) {
                RemoteImageView(url: release.imageUrl,
                                placeholder: UIImage(systemName: "music.note.list")!)
                    .height(60)
                    .width(60)
                
                VStack(alignment: .leading) {
                    Text(release.title)
                        .font(.headline)
                    Text(release.artistList)
                        .font(.subheadline)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
}

struct ReleaseDetailView: View {
    
    @ObservedObject private(set) var release:ReleaseViewModel
    let close:StandardAction
    
    @State private var draggedOffset:CGSize = .zero
    
    let radius:CGFloat = 24
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .foregroundColor(.black)
            
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
                    Button("Close", action: close)
                    
                    if let tracks = release.tracks {
                        ForEach(tracks, id: \.self) {
                            Text($0.displayText)
                                .foregroundColor(.pink)
                        }
                    }
                }
            }
        }
        .height(400)
        .cornerRadius(radius)
        .onAppear {
            release.getDetail()
        }
        .offset(draggedOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    print("Change value is \(value.translation)")
                    let xChange = abs(value.translation.width)
                    if draggedOffset == .zero && xChange <= 20 { return }
                    self.draggedOffset = value.translation
                }
                .onEnded{ value in
                    print("End value is \(value.translation)")
                    withAnimation(.easeIn) {
                        self.draggedOffset = .zero
                    }
                }
        )
        
    }
    
}

struct ReleaseListView_Previews: PreviewProvider {
    static var previews: some View {
        ReleaseListView()
    }
}
