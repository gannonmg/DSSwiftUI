//
//  Release+CoreDataClass.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/7/21.
//
//

import Foundation
import CoreData

@objc(Release)
public class Release: NSManagedObject {

    convenience init(context: NSManagedObjectContext, release: DCRelease, collection: ReleaseCollection) {
        self.init(context: context)
        
        self.uuid = UUID()
        
        self.title = release.basicInformation.title
        self.artist = release.basicInformation.artists.first?.name ?? "Unknown"
        self.urlString = release.basicInformation.coverImage
        
        let names = release.basicInformation.artists.map { $0.name }
        self.artists = names
        self.releaseYear = Int16(release.basicInformation.year)
        self.resourceUrl = release.basicInformation.resourceURL

        self.formats = release.basicInformation.formats.map { $0.name.lowercased() }
        self.genres = release.basicInformation.genres.map { $0.lowercased() }
        self.styles = release.basicInformation.styles.map { $0.lowercased() }
        self.descriptions = release.basicInformation.formats.map { $0.descriptions }.flatMap { $0 }.map { $0.lowercased() }

        self.collection = collection
    }
    
    func getTrackItems() -> [TrackItem]? {
        let storedTracks = tracks?.compactMap { $0 as? Track } ?? []
        let trackItems = storedTracks.map { TrackItem(from: $0) }
        return trackItems.isEmpty ? nil : trackItems
    }
    
}
