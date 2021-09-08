//
//  ReleaseViewModel.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/4/21.
//

import Foundation

class ReleaseViewModel: ObservableObject, Identifiable {
    
    let uuid: UUID
    
    let imageUrl: URL?
    let title: String
    
    let artist: String
    var artistList: String { artists.joined(separator: ", ") }
    private let artists: [String]
    
    let releaseYear: Int
    @Published private(set) var tracks: [TrackItem]?

    let resourceUrl: String
    
    let formats: [String]
    let genres: [String]
    let styles: [String]
    let descriptions: [String]

    //MARK: - Initializers
    init?(from storedRelease: Release) {

        self.uuid = storedRelease.uuid
        self.imageUrl = URL(string: storedRelease.urlString)
        self.title = storedRelease.title
        self.artist = storedRelease.artist
        self.artists = storedRelease.artists
        self.resourceUrl = storedRelease.resourceUrl
        
        self.formats = storedRelease.formats
        self.genres = storedRelease.genres
        self.styles = storedRelease.styles
        self.descriptions = storedRelease.formats
        
        if let tracks = storedRelease.getTrackItems() {
            self.tracks = tracks
        }
        
        self.releaseYear = Int(storedRelease.releaseYear)
    }
    
    //MARK: - Detail
    func getDetail() {
        guard tracks == nil || tracks?.isEmpty == true else { return }
        
        DCManager.shared.getDetail(for: resourceUrl) { detail in
            guard let detail = detail else { return }
            self.tracks = detail.tracklist.map { TrackItem(from: $0) }
            CoreDataManager.shared.addTracksToRelease(uuid: self.uuid, tracks: detail.tracklist)
        }
    }
    
    //MARK: - Geometry IDs
    var geoImage:String { "\(uuid).image" }
    var geoTitle:String { "\(uuid).title" }
    var geoArtist:String { "\(uuid).artist" }

}

struct TrackItem {
    
    let uuid = UUID()
    
    let title: String
    let duration: String
    
    var displayText: String {
        if duration.trimmingWhitespaces.isEmpty {
            return title
        } else {
            return "\(title) (\(duration))"
        }
    }
    
    init(from track: DCTrack) {
        self.title = track.title
        self.duration = track.duration
    }
    
    init(from track: Track) {
        self.title = track.title
        self.duration = track.duration
    }

}
