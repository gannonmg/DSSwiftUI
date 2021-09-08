//
//  Track+CoreDataProperties.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 9/8/21.
//
//

import Foundation
import CoreData


extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var title: String
    @NSManaged public var duration: String
    @NSManaged public var album: Release?

}

extension Track : Identifiable {

}
