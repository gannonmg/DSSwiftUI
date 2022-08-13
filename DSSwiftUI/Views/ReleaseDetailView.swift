//
//  ReleaseDetailView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/28/21.
//

import SwiftUI

struct SelectedReleaseView: View {
    
    @EnvironmentObject var realmListViewModel: ReleaseListViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var release: ReleaseViewModel
    
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
            
            if appViewModel.lastFmKey != nil {
                Button("Scrobble Album") {
                    RemoteClientManager.shared.scrobbleRelease(release)
                }
                .testIdentifier(ReleaseDetailIdentifier.scrobbleButton)
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
            do {
                try await release.getDetail()
            } catch {
                errorHandling.handle(error: error)
            }
        }
    }
    
}
