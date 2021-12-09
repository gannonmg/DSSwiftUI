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
                    .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $viewModel.showingFilters) {
            FilterView(filterController: viewModel.filterController)
        }
    }
    
    var conditionalView: some View {
        if viewModel.releases.isEmpty {
            return AnyView(Button("Get Releases", action: viewModel.getReleases)
                            .buttonStyle(.bordered))
        } else {
            return AnyView(listView)
        }
    }
    
    var listView: some View {
        SwiftUI.List {
//            let predicate = viewModel.filterController.predicate
//            let smartSearchMatcher = SmartSearchMatcher(searchString: viewModel.searchQuery)
//            let releases = ((predicate == nil) ? releases : releases.filter(predicate!))
            
            ForEach(viewModel.releases) { release in
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
        .searchable(text: $viewModel.searchQuery)
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

struct SelectedReleaseView: View {
    
    @EnvironmentObject var realmListViewModel: RealmListViewModel
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
                        realmListViewModel.randomizedRelease = nil
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
