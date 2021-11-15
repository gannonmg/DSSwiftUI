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
    init(from dcRelease: DCRelease) {
        self.uuid = UUID()
        self.imageUrl = URL(string: dcRelease.basicInformation.coverImage)
        self.title = dcRelease.basicInformation.title
        self.artist = dcRelease.basicInformation.artists.first?.name ?? ""
        self.artists = dcRelease.basicInformation.artists.map { $0.name }
        self.resourceUrl = dcRelease.basicInformation.resourceURL
        
        self.formats = dcRelease.basicInformation.formats.map { $0.name.lowercased() }
        self.genres = dcRelease.basicInformation.genres.map { $0.lowercased() }
        self.styles = dcRelease.basicInformation.styles.map { $0.lowercased() }
        self.descriptions = dcRelease.basicInformation.formats.map { $0.descriptions }.flatMap { $0 }.map { $0.lowercased() }

        self.releaseYear = dcRelease.basicInformation.year
    }

    //MARK: - Detail
    func getDetail() {
        guard tracks == nil || tracks?.isEmpty == true else { return }
        
        DCManager.shared.getDetail(for: resourceUrl) { detail in
            guard let detail = detail else { return }
            self.tracks = detail.tracklist.map { TrackItem(from: $0) }
//            CoreDataManager.shared.addTracksToRelease(uuid: self.uuid, tracks: detail.tracklist)
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
    
}
