//
//  ReleaseViewModel.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/4/21.
//

import Foundation

class ReleaseViewModel: ObservableObject, Identifiable {
    
    let uuid = UUID()
    
    @Published private(set) var imageUrl: URL?
    @Published private(set) var title: String
    
    @Published private(set) var firstArtist: String
    @Published private(set) var artists: [String]
    @Published private(set) var artistList: String
    
    @Published private(set) var releaseYear: Int
    @Published private(set) var tracks: [DCTrack]?

    let resourceUrl: String
    
    let formats: [String]
    let genres: [String]
    let styles: [String]
    let descriptions: [String]

    //MARK: - Initializers
    init(from dcRelease: DCRelease) {
        self.title = dcRelease.basicInformation.title
        self.firstArtist = dcRelease.basicInformation.artists.first?.name ?? "Unknown"
        self.imageUrl = URL(string: dcRelease.basicInformation.coverImage)

        let names = dcRelease.basicInformation.artists.map { $0.name }
        self.artists = names
        self.artistList = names.joined(separator: ", ")
        self.releaseYear = dcRelease.basicInformation.year
        
        self.resourceUrl = dcRelease.basicInformation.resourceURL
        
        self.formats = dcRelease.basicInformation.formats.map { $0.name.lowercased() }
        self.genres = dcRelease.basicInformation.genres.map { $0.lowercased() }
        self.styles = dcRelease.basicInformation.styles.map { $0.lowercased() }
        self.descriptions = dcRelease.basicInformation.formats.map { $0.descriptions }.flatMap { $0 }.map { $0.lowercased() }
    }
    
    init(title: String, artist: String) {
        self.imageUrl = nil
        self.title = title
        self.artistList = artist
        self.artists = [artist]
        self.firstArtist = artist
        self.releaseYear = -1
        self.resourceUrl = ""

        self.formats = []
        self.genres = []
        self.styles = []
        self.descriptions = []
    }
    
    init?(from storedRelease: Release) {
        guard let title = storedRelease.title,
              let artist = storedRelease.artist,
              let artists = storedRelease.artists,
              let urlString = storedRelease.urlString,
              let resourceUrl = storedRelease.resourceUrl
        else { return nil }
        
        self.imageUrl = URL(string: urlString)
        self.title = title
        self.artistList = artist
        self.artists = artists
        self.resourceUrl = resourceUrl
        
        #warning("Update to store these in CoreData")
        self.formats = storedRelease.formats ?? []
        self.genres = storedRelease.genres ?? []
        self.styles = storedRelease.styles ?? []
        self.descriptions = storedRelease.formats ?? []
        
        self.releaseYear = -1
        self.firstArtist = ""
        
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
