//
//  RealmManager.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/25/21.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared: RealmManager = .init()
    private init() {}
    
    func deleteAllReleases() {
        do {
            let realm: Realm = try .init()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Failed to delete all releases")
        }
    }
    
    func add(releases: [DCReleaseModel]) {
        do {
            let realm: Realm = try .init()
            try realm.write {
                realm.add(releases)
            }
        } catch {
            print("Failed to add all releases")
        }
    }
    
    func add(detail: DCReleaseDetailModel) {
        do {
            let realm: Realm = try .init()
            try realm.write {
                realm.add(detail)
            }
        } catch {
            print("Failed to add detail")
        }
    }
    
    func get(for discogsId: Int) -> DCReleaseDetailModel? {
        do {
            let realm: Realm = try .init()
            return realm.object(ofType: DCReleaseDetailModel.self,
                                forPrimaryKey: discogsId)
        } catch {
            print("Failed to get detail")
            return nil
        }
    }
    
    func getAllReleases() -> [DCReleaseModel]? {
        do {
            let realm: Realm = try .init()
            return Array(realm.objects(DCReleaseModel.self))
        } catch {
            print("Failed to get detail")
            return nil
        }
    }
    
    func update(with releases: [DCReleaseModel]) {
        do {
            let realm: Realm = try .init()
            try realm.write {
                for release in releases {
                    let object: DCReleaseModel? = realm.object(
                        ofType: DCReleaseModel.self,
                        forPrimaryKey: release.instanceId
                    )
                    
                    if object == nil {
                        realm.add(release)
                    } else {
                        #warning("TODO: Figure out what updates object might need")
                    }
                }
            }
        } catch {
            print("Failed to add all releases \(error)")
        }
    }
    
}
