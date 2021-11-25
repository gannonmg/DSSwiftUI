//
//  RealmManager.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/25/21.
//

import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    private init() {}
    
    func deleteAllReleases() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Failed to delete all releases")
        }
    }
    
    func add(releases: [RealmReleaseCodable]) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(releases)
            }
        } catch {
            print("Failed to add all releases")
        }
    }
    
    func update(with releases: [RealmReleaseCodable]) {
        do {
            let realm = try Realm()
            try realm.write {
                for release in releases {
                    let object = realm.object(ofType: RealmReleaseCodable.self, forPrimaryKey: release.instanceId)
                    if object == nil {
                        realm.add(release)
                    } else {
                        //TODO: - Update object
                    }
                }
            }
        } catch {
            print("Failed to add all releases")
        }
    }
    
}
