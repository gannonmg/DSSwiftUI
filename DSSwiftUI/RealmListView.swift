//
//  RealmListView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/10/21.
//

import RealmSwift
import SwiftUI

let sharedRealm = try! Realm()

struct RealmCollectionReleasesResponse: Codable {
    let pagination: Pagination
    let releases: [RealmReleaseCodable]
}

class RealmReleaseCodable: Object, ObjectKeyIdentifiable, Codable {
    @Persisted private(set) var basicInformation: RealmBasicInformation?
    
    enum CodingKeys: String, CodingKey {
        case basicInformation = "basic_information"
    }

}

class RealmBasicInformation: Object, Codable {
    
    @Persisted private(set) var title: String
    @Persisted private(set) var year: Int
//    @Persisted private(set) var artists: [RealmArtistCodable]
    @Persisted private(set) var coverImage: String
    
    enum CodingKeys: String, CodingKey {
        case title, year//, artists
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
//    let artist: String

    init(from release: RealmReleaseCodable) {
        self.uuid = UUID()
        self.imageUrl = URL(string: release.basicInformation!.coverImage)
        self.title = release.basicInformation!.title
//        self.artist = release.basicInformation.artists.first?.name ?? ""
    }
    
}

struct RealmListView: View {
    
    @ObservedResults(RealmReleaseCodable.self) var releases
    
    var body: some View {
        if releases.isEmpty {
            Button("Get Releases", action: getReleases)
        } else {
            List {
                ForEach(releases) { release in
                    Text(release.basicInformation?.title ?? "No title")
                }
            }
        }
    }
    
    func getReleases() {
        DCManager.shared.getAllReleasesForUser { releases in
            try! sharedRealm.write {
                sharedRealm.add(releases)
            }
        }
    }
    
}
