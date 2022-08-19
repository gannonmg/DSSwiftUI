//
//  ReleaseDetailView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/28/21.
//

import SwiftUI

struct ReleaseDetailView: View {
    
    @EnvironmentObject var realmListViewModel: ReleaseListViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    @ObservedObject var release: ReleaseViewModel
    @Environment(\.dismiss) var dismiss: DismissAction
    
    var body: some View {
        VStack(spacing: 0) {
            imageArea
            if release.tracklist.isEmpty {
                Spacer()
            } else {
                TrackListView(release: release)
            }
        }
        .onAppear(perform: getDetail)
        .background(Color.vsPrimaryDark)
        .overlay(
            alignment: .topTrailing,
            content: { closeButton }
        )
    }
    
    var imageArea: some View {
        ZStack {
            RemoteImageView(
                url: URL(string: release.coverImage),
                placeholder: UIImage(systemName: "photo")!
            )
            
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading) {
                Spacer()
                Text(release.title)
                    .appFont(.robotoBold, size: 28)
                    .foregroundColor(.white)
                Text(release.artistList)
                    .appFont(.robotoBold, size: 20)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: DEVICE_WIDTH, height: DEVICE_WIDTH)
    }
    
    var closeButton: some View {
        Button {
            dismiss()
        } label: {
            ZStack {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                Image.closeIcon
                    .foregroundColor(.black)
            }
        }
        .padding(.top, 16)
        .padding(.trailing, 12)
        .shadow(
            color: .vsShadowColor,
            radius: 4,
            x: 0, y: 4
        )
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

struct TrackListView: View {
    @ObservedObject var release: ReleaseViewModel
    
    @State private var positionWidth: CGFloat?
    @State private var bottomOffset: CGFloat?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 2) {
                ForEach(release.tracklist) { track in
                    HStack {
                        trackView(track)
                        Spacer()
                        if !track.duration.isEmpty {
                            Text("\(track.duration)")
                                .appFont(.robotoMedium, size: 14)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 20)
            .padding(.bottom, bottomOffset ?? 0)
        }
        .overlay(alignment: .bottom, content: { lastFmButton })
        .onPreferenceChange(PositionWidthPreferenceKey.self) { newWidth in
            self.positionWidth = newWidth
        }
        .onPreferenceChange(LastFmHeightPrefKey.self) { newHeight in
            self.bottomOffset = newHeight
        }
    }
    
    func trackView(_ track: DCTrackModel) -> some View {
        HStack(alignment: .top, spacing: 4) {
            let position: Int = release.tracklist.firstIndex(of: track)! + 1
            Text("\(position).")
                .appFont(.robotoBold, size: 20)
                .foregroundColor(.white)
                .background(GeometryReader { geometry in
                    Color.clear.preference(
                        key: PositionWidthPreferenceKey.self,
                        value: geometry.size.width
                    )
                })
                .frame(width: positionWidth)
            
            Text("\(track.title)")
                .appFont(.robotoBold, size: 20)
                .foregroundColor(.white)
        }
    }
    
    var lastFmButton: some View {
        VSButton("last.fm", buttonStyle: .light) {
            // do something
        }
        .background(GeometryReader { geometry in
            Color.clear.preference(
                key: LastFmHeightPrefKey.self,
                value: geometry.size.height
            )
        })
        .padding(.horizontal, 20)
        .background {
            LinearGradient(
                colors: [.clear, .black.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
    
    struct PositionWidthPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat,
                           nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    
    struct LastFmHeightPrefKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat,
                           nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
