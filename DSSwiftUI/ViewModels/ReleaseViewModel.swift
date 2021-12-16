//
//  ReleaseViewModel.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/13/21.
//

import Foundation

class ReleaseViewModel: ObservableObject, Identifiable {
    
    let id: Int // This is the instance id from discogs and is unique even among duplicate albums
    let discogsId: Int // This is unique to the release, but not instances of the release
    
    let title: String
    let year: Int
    let artists: [DCArtistModel]
    let coverImage: String
    let resourceURL: String
    
    let formats: [String]
    let descriptions: [String]
    let genres: [String]
    let styles: [String]
    
    @Published private(set) var tracklist: [DCTrackModel] = []
    
    var firstArtist: String {
        return self.artists.first?.name ?? ""
    }
    
    var artistList: String {
        return self.artists.map { $0.name }.joined(separator: ", ")
    }

    init(from release: DCReleaseModel) {
        self.id = release.instanceId
        self.discogsId = release.id
        self.title = release.basicInformation.title
        self.year = release.basicInformation.year
        self.artists = Array(release.basicInformation.artists)
        self.coverImage = release.basicInformation.coverImage
        self.resourceURL = release.basicInformation.resourceURL
        
        self.genres = Array(release.basicInformation.genres)
        self.styles = Array(release.basicInformation.styles)
        self.formats = release.basicInformation.formats.map { $0.name }
        self.descriptions = Array(release.basicInformation.formats.map { Array($0.descriptions) })
            .flatMap { $0 }
    }
    
    func getDetail() async {
        
        if let details = RealmManager.shared.get(for: discogsId) {
            tracklist = Array(details.tracklist)
            return
        }
        
        if let details = await DCManager.shared.getDetail(for: resourceURL) {
            DispatchQueue.main.async {
                self.tracklist = Array(details.tracklist)
                RealmManager.shared.add(detail: details)
            }
        }
    }
    
}
