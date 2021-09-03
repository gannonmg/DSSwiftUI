//
//  ReleaseListView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/4/21.
//

import SwiftUI
import Combine

struct ReleaseListView: View {
    
    @Namespace private var namespace
    @StateObject private var releaseCollectionViewModel: ReleaseCollectionViewModel = .init()
    
    var body: some View {
        NavigationView {
            if let selected = releaseCollectionViewModel.selected {
                ReleaseDetailView(namespace: namespace,
                                  release: selected,
                                  onClose: { releaseCollectionViewModel.selected = nil })
            } else {
                CollectionView(releaseCollectionViewModel: releaseCollectionViewModel,
                               namespace: namespace,
                               tappedRelease: tappedRelease(_:))
            }
        }
        .sheet(isPresented: $releaseCollectionViewModel.showingFilters) {
            FilterView(filterController: releaseCollectionViewModel.filterController)
        }
    }
    
    func tappedRelease(_ release: ReleaseViewModel) {
        withAnimation(.easeInOut) {
            releaseCollectionViewModel.selected = release
        }
    }
    
}

struct CollectionView: View {
    
    @ObservedObject var releaseCollectionViewModel: ReleaseCollectionViewModel
    let namespace: Namespace.ID
    var tappedRelease: ((ReleaseViewModel)->Void)

//    @State private var showingGridView = true
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 0) {
                    RefreshControl(coordinateSpace: .named("RefreshControl"),
                                   onRefresh: onRefresh)
                    
                    if releaseCollectionViewModel.releases.isEmpty {
                        Button("Get releases") {
                            releaseCollectionViewModel.getReleases()
                        }
                    } else {
//                        if showingGridView {
//                            ReleaseGridView(releaseCollectionViewModel: releaseCollectionViewModel,
//                                            namespace: namespace,
//                                            tappedRelease: tappedRelease)
//                        } else {
                            CollectionListView(releaseCollectionViewModel: releaseCollectionViewModel,
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
        releaseCollectionViewModel.getReleases()
    }
    
}

struct CollectionListView: View {
    
    @ObservedObject var releaseCollectionViewModel: ReleaseCollectionViewModel
    let namespace: Namespace.ID
    var tappedRelease: ((ReleaseViewModel)->Void)

    var body: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            let header = SearchBarView(releaseCollectionViewModel: releaseCollectionViewModel,
                                       showingFilters: $releaseCollectionViewModel.showingFilters)
            Section(header: header) {
                let filtered = releaseCollectionViewModel.filterController.filteredReleases
                    .sorted(by: { $0.artist < $1.artist })
                ForEach(filtered, id: \.uuid) { release in
                    ReleaseListItemView(namespace: namespace, release: release)
                        .onTapGesture { tappedRelease(release) }
                }
            }
        }
        .padding(.all, 0)
    }
    
}

struct CollectionGridView: View {
    
    @ObservedObject var releaseCollectionViewModel: ReleaseCollectionViewModel
    let namespace: Namespace.ID
    var tappedRelease: ((ReleaseViewModel)->Void)
    
    let columns:[GridItem] = Array(repeating: .init(spacing: 0), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0, pinnedViews: .sectionHeaders) {
            let header = SearchBarView(releaseCollectionViewModel: releaseCollectionViewModel,
                                       showingFilters: $releaseCollectionViewModel.showingFilters)
            Section(header: header) {
                let filtered = releaseCollectionViewModel.filterController.filteredReleases
                    .sorted(by: { $0.artist < $1.artist })
                ForEach(filtered, id: \.uuid) { release in
                    ReleaseGridItemView(namespace: namespace, release: release)
                        .onTapGesture { tappedRelease(release) }
                }
            }
        }
    }
    
}

private struct SearchBarView: View {
    
    @ObservedObject var releaseCollectionViewModel: ReleaseCollectionViewModel
    @Binding var showingFilters: Bool
    
    var body: some View {
        
        VStack(spacing: 0) {
            HStack {
                let count = releaseCollectionViewModel.releases.count
                let string = "\(count) Release\(count == 1 ? "" : "s")"
                TextField("Search \(string)", text: releaseCollectionViewModel.$filterController.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                let filterCount = releaseCollectionViewModel.filterController.selectedFilters.count
                let filterString = filterCount == 0 ? "Filters" : "Filters (\(filterCount))"
                Button(filterString) {
                    showingFilters = true
                }
                .padding(.trailing, 12)
            }
            .padding(.all, 8)
            Color.separator.height(1)
        }
        .background(searchBackground)
    }
    
    private var searchBackground: some View {
        ZStack {
            Blur(style: .systemThinMaterial).opacity(0.7)
            Color.navBar.opacity(0.8)
        }
    }
    
    private struct Blur: UIViewRepresentable {
        
        init(style: UIBlurEffect.Style) {
            self.style = style
        }
        
        let style: UIBlurEffect.Style
        
        func makeUIView(context: Context) -> UIVisualEffectView {
            return UIVisualEffectView(effect: UIBlurEffect(style: style))
        }
        
        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
            uiView.effect = UIBlurEffect(style: style)
        }
    }
    
}

struct ReleaseGridItemView: View {
    
    let namespace:Namespace.ID
    let release:ReleaseViewModel
    
    var body: some View {
        RemoteImageView(url: release.imageUrl,
                        placeholder: UIImage(systemName: "music.note.list")!)
            .matchedGeometryEffect(id: release.geoImage, in: namespace)
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fill)
    }
    
}

struct ReleaseListItemView: View {
    
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

struct ReleaseListView_Previews: PreviewProvider {
    static var previews: some View {
        ReleaseListView()
    }
}
