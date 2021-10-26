//
//  ReleaseDetailView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 9/3/21.
//

import SwiftUI

struct ReleaseDetailView: View {
    
    let namespace: Namespace.ID
    @ObservedObject var release: ReleaseViewModel
    var onClose: StandardAction

    var tracks:[TrackItem] { release.tracks ?? [] }
    
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
                    ForEach(tracks, id: \.uuid) {
                        Text($0.displayText)
                            .foregroundColor(.pink)
                    }
                }
            }
        }
        .background(Color(.backgroundColor))
        .onAppear {
            release.getDetail()
        }
        
    }
    
}
