//
//  Track+CoreDataClass.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 9/8/21.
//
//

import Foundation
import CoreData

@objc(Track)
public class Track: NSManagedObject {

    convenience init(context: NSManagedObjectContext, track: DCTrack, release: Release) {
        self.init(context: context)
        self.title = track.title
        self.duration = track.duration.trimmingWhitespaces
        self.album = release
    }
    
}
