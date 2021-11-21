//
//  RealmListView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/10/21.
//

import RealmSwift
import SwiftUI

struct RealmCollectionReleasesResponse: Codable {
    let pagination: Pagination
    let releases: [RealmReleaseCodable]
}

class RealmReleaseCodable: Object, ObjectKeyIdentifiable, Codable {
    
    @Persisted private(set) var basicInformation: RealmBasicInformation!
    
    enum CodingKeys: String, CodingKey {
        case basicInformation = "basic_information"
    }

}

class RealmBasicInformation: Object, Codable {
    
    @Persisted private(set) var title: String
    @Persisted private(set) var year: Int
    @Persisted private(set) var artists: RealmSwift.List<RealmArtistCodable>
    @Persisted private(set) var coverImage: String
    
    enum CodingKeys: String, CodingKey {
        case title, year, artists
        case coverImage = "cover_image"
    }

}

class RealmArtistCodable: Object, Codable {
    @Persisted private(set) var name: String
}

class RealmReleaseViewModel: ObservableObject, Identifiable {
    
    var uuid: UUID
    let imageUrl: URL?
    let title: String
    let artist: String

    init(from release: RealmReleaseCodable) {
        self.uuid = UUID()
        self.imageUrl = URL(string: release.basicInformation.coverImage)
        self.title = release.basicInformation.title
        self.artist = release.basicInformation.artists.first?.name ?? ""
    }
    
    lazy var itemString: String = { title + " - " }()
    
}

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
    
}

struct RealmListView: View {
    
    @ObservedResults(RealmReleaseCodable.self) var releases
    
    var body: some View {
        VStack {
            Button("Delete all in Realm", action: deleteReleases)
            Button("Get Releases", action: getReleases)
            SwiftUI.List {
                ForEach(releases) { release in
                    Text(release.basicInformation.title)
//                    let vm = RealmReleaseViewModel(from: release)
//                    Text(vm.itemString)
                }
            }
        }
    }
    
    func deleteReleases() {
        RealmManager.shared.deleteAllReleases()
    }
    
    func getReleases() {
        DCManager.shared.getAllReleasesForUser { releases in
            RealmManager.shared.add(releases: releases)
        }
    }
    
}
