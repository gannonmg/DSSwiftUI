//
//  RealmListView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/10/21.
//

import SwiftUI

struct ReleaseListView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject var viewModel = ReleaseListViewModel()
    @State private var showingLastFmLogin: Bool = false
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 0) {
                    searchView
                    conditionalView
                }
                .background { Color.secondaryBackground }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    leadingItem
                    shuffleItem
                    ToolbarItem(placement: .principal, content: { Text("Collection") })
                    trailingItem
                }
            }
            
            if let selectedRelease = viewModel.selectedRelease {
                SelectedReleaseView(release: selectedRelease)
                    .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $viewModel.showingFilters) {
            FilterView()
                .environmentObject(viewModel.filterController)
        }
        .sheet(isPresented: $showingLastFmLogin) {
            LFLoginView()
                .environmentObject(appViewModel)
        }
    }
    
    var conditionalView: some View {
        if viewModel.trulyEmpty {
            return AnyView(getReleasesView)
        } else if viewModel.releases.isEmpty {
            return AnyView(noSearchResultsView)
        } else {
            return AnyView(listView)
        }
    }
    
    var getReleasesView: some View {
        Button("Get Releases", action: viewModel.getRemoteReleases)
                .buttonStyle(.bordered)
                .frame(maxHeight: .infinity)
    }
    
    var listView: some View {
        List {
            ForEach(viewModel.releases) { release in
                ReleaseListItemView(release: release)
                    .onTapGesture {
                        viewModel.setSelectedRelease(release)
                    }
            }
        }
        .refreshable {
            viewModel.getRemoteReleases()
        }
    }
    
    var searchView: some View {
        VStack(alignment: .leading) {
            TextField("Search", text: $viewModel.searchQuery)
                .textFieldStyle(.roundedBorder)
            HStack {
                let resultsCount = viewModel.releases.count
                Text("\(resultsCount) \(resultsCount == 1 ? "Result" : "Results")")
                    .font(.caption)
                Spacer()
                Button("Clear Filters", action: viewModel.clearSearchAndFilter)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background { Color.background }
    }
    
    var noSearchResultsView: some View {
        VStack {
            Text("No albums matched your filter criteria")
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    var leadingItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                Button("Log Out", role: .destructive,
                       action: appViewModel.logOutAll)
                Button("Delete Collection", role: .destructive,
                       action: RealmManager.shared.deleteAllReleases)
                lastFmButton
            } label: {
                Image(systemName: "gearshape.fill")
            }
        }
    }
    
    var lastFmButton: some View {
        if appViewModel.lastFmKey != nil {
            return Button("Last.FM Logout", role: .destructive) {
                appViewModel.logOutLastFm()
            }
        } else {
            return Button("Last.FM Login") {
                showingLastFmLogin = true
            }
        }
    }
    
    var shuffleItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                viewModel.pickRandomRelease()
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

}

struct ReleaseListItemView: View {
    
    let release: ReleaseViewModel

    var body: some View {
        VStack(alignment: .leading) {
            
            HStack(alignment: .top) {
                RemoteImageView(url: URL(string: release.coverImage),
                                placeholder: UIImage(systemName: "photo")!)
                    .height(40)
                    .width(40)
                VStack(alignment: .leading) {
                    Text(release.title)
                    Text(release.artists.first?.name ?? "")
                        .font(.callout)
                }
            }
            
            Text("Genres: " + release.genres.map { $0 }.joined(separator: ", "))
                .font(.caption)
            Text("Styles: " + release.styles.map { $0 }.joined(separator: ", "))
                .font(.caption)
            Text("Formats: " + release.formats.map { $0 }.joined(separator: ", "))
                .font(.caption)
            Text("Descriptions: " + release.descriptions.joined(separator: ", "))
                .font(.caption)
        }
    }
    
}

struct SelectedReleaseView: View {
    
    @EnvironmentObject var realmListViewModel: ReleaseListViewModel
    @ObservedObject var release: ReleaseViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            (colorScheme == .light ? Color.black : Color.white)
                .opacity(0.3)
                .ignoresSafeArea()
            content
        }
        .onAppear(perform: getDetail)
    }
    
    var content: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                HStack {
                    RemoteImageView(url: URL(string: release.coverImage),
                                    placeholder: UIImage(systemName: "photo")!)
                        .height(80)
                        .width(80)
                    
                    VStack(alignment: .leading) {
                        Text(release.title)
                        Text(release.artists.first!.name)
                            .font(.callout)
                    }
                    
                    Spacer()
                }
                
                closeButton
            }
            
            if KeychainManager.shared.get(for: .lastFmSessionKey) != nil {
                Button("Scrobble Album") {
                    LFManager.shared.scrobbleRelease(release)
                }
            }
            
            VStack {
                ForEach(release.tracklist) { track in
                    HStack(alignment: .top) {
                        Text("\(track.title)")
                        Spacer()
                        if !track.duration.isEmpty {
                            Text("\(track.duration)")
                        }
                    }
                }
            }
            .padding()
        }
        .background { Color.secondaryBackground }
        .padding(.horizontal, 20)
    }
    
    var closeButton: some View {
        Button {
            realmListViewModel.removeRandomeRelease()
        } label: {
            Image(systemName: "x.circle.fill")
                .height(28)
                .width(28)
                .foregroundColor(.white)
                .background {
                    Color.black
                        .height(28)
                        .width(28)
                        .cornerRadius(14)
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
        }
    }
    
    func getDetail() {
        Task {
            await release.getDetail()
        }
    }
    
}
