//
//  ReleaseCollection+CoreDataProperties.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/7/21.
//
//

import Foundation
import CoreData


extension ReleaseCollection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReleaseCollection> {
        return NSFetchRequest<ReleaseCollection>(entityName: "ReleaseCollection")
    }

    @NSManaged public var releaseItem: NSSet?

}

// MARK: Generated accessors for releaseItem
extension ReleaseCollection {

    @objc(addReleaseItemObject:)
    @NSManaged public func addToReleaseItem(_ value: Release)

    @objc(removeReleaseItemObject:)
    @NSManaged public func removeFromReleaseItem(_ value: Release)

    @objc(addReleaseItem:)
    @NSManaged public func addToReleaseItem(_ values: NSSet)

    @objc(removeReleaseItem:)
    @NSManaged public func removeFromReleaseItem(_ values: NSSet)

}

extension ReleaseCollection : Identifiable {

}
