//
//  RealmListView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/10/21.
//

import SwiftUI

struct RealmListView: View {
    
    @StateObject var viewModel = RealmListViewModel()
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 0) {
                    searchView
                    conditionalView
                }
                .background { Color.lightGreyColor }
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
        VStack(alignment: .center) {
            Spacer()
            Button("Get Releases", action: viewModel.getReleases)
                    .buttonStyle(.bordered)
            Spacer()
        }
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
        .onAppear {
            UITableView.appearance().contentInset.top = -27
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
        .background { Color.white }
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
    
    @EnvironmentObject var realmListViewModel: RealmListViewModel
    @ObservedObject var release: ReleaseViewModel
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
            content
        }
        .onAppear(perform: getDetail)
    }
    
    var content: some View {
        VStack(alignment: .leading) {
            HStack {
                ZStack(alignment: .topLeading) {
                    RemoteImageView(url: URL(string: release.coverImage),
                                    placeholder: UIImage(systemName: "photo")!)
                        .height(80)
                        .width(80)
                    closeButton
                }
                
                VStack(alignment: .leading) {
                    Text(release.title)
                    Text(release.artists.first!.name)
                        .font(.callout)
                }
            }
            
            ForEach(release.tracklist) { track in
                Text("\(track.title)")
            }
            
        }
        .background { Color.white }
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    var closeButton: some View {
        Button {
            realmListViewModel.removeRandomeRelease()
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
    
    func getDetail() {
//        release.basicInformation.getDetail()
        Task {
            await release.getDetail()
        }
    }
    
}
