//
//  Release+CoreDataProperties.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/7/21.
//
//

import Foundation
import CoreData


extension Release {

    @nonobjc class func fetchRequest() -> NSFetchRequest<Release> {
        return NSFetchRequest<Release>(entityName: "Release")
    }

    @NSManaged var uuid: UUID
    
    @NSManaged var title: String
    @NSManaged var artist: String
    @NSManaged var artists: [String]
    @NSManaged var releaseYear: Int16

    @NSManaged var urlString: String
    @NSManaged var resourceUrl: String
    
    @NSManaged var descriptions: [String]
    @NSManaged var formats: [String]
    @NSManaged var genres: [String]
    @NSManaged var styles: [String]
    
    @NSManaged var tracks: NSSet?
    
    @NSManaged var collection: ReleaseCollection?

}

extension Release {

    @objc(addTracksObject:)
    @NSManaged public func addToTracks(_ value: Track)

    @objc(removeTracksObject:)
    @NSManaged public func removeFromTracks(_ value: Track)

    @objc(addTracks:)
    @NSManaged public func addToTracks(_ values: NSSet)

    @objc(removeTracks:)
    @NSManaged public func removeFromTracks(_ values: NSSet)

}


extension Release : Identifiable {

}
