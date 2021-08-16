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

    @NSManaged var artist: String?
    @NSManaged var artists: [String]?
    @NSManaged var descriptions: [String]?
    @NSManaged var formats: [String]?
    @NSManaged var genres: [String]?
    @NSManaged var styles: [String]?
    @NSManaged var title: String?
    @NSManaged var urlString: String?
    @NSManaged var releaseYear: Int16
    @NSManaged var collection: ReleaseCollection?
    @NSManaged var resourceUrl: String?

}

extension Release : Identifiable {

}
