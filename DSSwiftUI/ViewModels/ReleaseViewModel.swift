//
//  ReleaseViewModel.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/4/21.
//

import Foundation

class ReleaseViewModel: ObservableObject, Identifiable {
    
    let uuid = UUID()
    
    let imageUrl: URL?
    let title: String
    
    let artist: String
    var artistList: String { artists.joined(separator: ", ") }
    private let artists: [String]
    
    let releaseYear: Int
    @Published private(set) var tracks: [DCTrack]?

    let resourceUrl: String
    
    let formats: [String]
    let genres: [String]
    let styles: [String]
    let descriptions: [String]

    //MARK: - Initializers
    init?(from storedRelease: Release) {

        self.imageUrl = URL(string: storedRelease.urlString)
        self.title = storedRelease.title
        self.artist = storedRelease.artist
        self.artists = storedRelease.artists
        self.resourceUrl = storedRelease.resourceUrl
        
        self.formats = storedRelease.formats
        self.genres = storedRelease.genres
        self.styles = storedRelease.styles
        self.descriptions = storedRelease.formats
        
        self.releaseYear = Int(storedRelease.releaseYear)
    }
    
    //MARK: - Detail
    func getDetail() {
        DCManager.shared.getDetail(for: resourceUrl) { detail in
            guard let detail = detail else {
                print("Did not get detail")
                return
            }
            print("Got detail")
            print("Tracklist: \(detail.tracklist)")
            self.tracks = detail.tracklist
        }
    }
    
}
