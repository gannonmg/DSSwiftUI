//
//  RealmModels.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/25/21.
//

import Combine
import Foundation
import RealmSwift

struct RealmCollectionReleasesResponse: Codable {
    let pagination: Pagination
    let releases: [RealmReleaseCodable]
}

//MARK: - Errors
enum DCError: Error {
    case releaseFailure
    case releaseDetailFailure
}

// MARK: - DCUser
struct DCUser: Codable {
    let id: Int
    let username: String
    let resource_url: String
}

// MARK: - Pagination
struct Pagination: Codable {
    let page, pages, perPage, items: Int
    let urls: Urls
    
    enum CodingKeys: String, CodingKey {
        case page, pages
        case perPage = "per_page"
        case items, urls
    }
}

// MARK: - Urls
struct Urls: Codable {
    let first, last, prev, next: String?
}

class RealmReleaseCodable: Object, ObjectKeyIdentifiable, Codable {
    
    override static func primaryKey() -> String? {
        return "instanceId"
    }

    ///The unique identifier release for this album in the collection. Two identical albums in a collection will have different instanceIds.
    @Persisted private(set) var instanceId: Int
    @Persisted private(set) var basicInformation: RealmBasicInformation!
    
    enum CodingKeys: String, CodingKey {
        case instanceId = "instance_id",
             basicInformation = "basic_information"
    }
    
    //Convenience
    var tracks: [RealmTrackCodable] { self.basicInformation.tracks ?? [] }

}

class RealmBasicInformation: Object, Codable {
    
    @Persisted private(set) var title: String
    @Persisted private(set) var year: Int
    @Persisted private(set) var artists: List<RealmArtistCodable>
    @Persisted private(set) var coverImage: String
    @Persisted private(set) var resourceURL: String
    @Persisted private(set) var formats: List<RealmFormatCodable>
    @Persisted private(set) var genres: List<String>
    @Persisted private(set) var styles: List<String>
    
    @Published private(set) var tracks: [RealmTrackCodable]? {
        didSet {
            print("Tracks changed")
        }
    }

    enum CodingKeys: String, CodingKey {
        case title, year, artists, genres, styles, formats
        case coverImage = "cover_image"
        case resourceURL = "resource_url"
    }
    
//    func getDetail() async {
//        if let detail = await DCManager.shared.getDetail(for: self.resourceURL) {
//            print("Detail gotten")
//            self.tracks = Array(detail.tracklist)
////            print("Tracks are \(self.tracks ?? [])")
//        }
//    }

    func getDetail() {
        DCManager.shared.getDetail(for: self.resourceURL) { detail in
            guard let detail = detail else {
                print("Unable to fetch detail")
                return
            }

            self.tracks = Array(detail.tracklist)
        }
    }
}

class RealmArtistCodable: Object, Codable {
    @Persisted private(set) var name: String
}

class RealmFormatCodable: Object, Codable {
    
    @Persisted private(set) var name: String
    @Persisted private(set) var descriptions: List<String>
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.descriptions = try container.decodeIfPresent(List<String>.self, forKey: .descriptions) ?? List<String>()
    }
}

class RealmReleaseDetailCodable: Object, Codable {
    
    @Persisted private(set) var id: Int
    @Persisted private(set) var tracklist: List<RealmTrackCodable>

    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.tracklist = try container.decodeIfPresent(List<RealmTrackCodable>.self, forKey: .tracklist) ?? List<RealmTrackCodable>()
    }
    
}

class RealmTrackCodable: Object, Codable, Identifiable {
    
    let id = UUID()
    
    @Persisted private(set) var position: String
    @Persisted private(set) var type: String
    @Persisted private(set) var title: String
    @Persisted private(set) var duration: String
    @Persisted private(set) var extraArtists: List<RealmArtistCodable>
    
    enum CodingKeys: String, CodingKey {
        case type = "type_"
        case extraArtists = "extraartists"
        case title, duration, position
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.title = try container.decode(String.self, forKey: .title)
        self.duration = try container.decode(String.self, forKey: .duration)
        self.position = try container.decode(String.self, forKey: .position)
        self.extraArtists = try container.decodeIfPresent(List<RealmArtistCodable>.self, forKey: .extraArtists) ?? List<RealmArtistCodable>()
    }
    
}

class ReleaseViewModel: ObservableObject, Identifiable {
    
    let id: Int
    
    let title: String
    let year: Int
    let artists: [RealmArtistCodable]
    let coverImage: String
    let resourceURL: String
    
    let formats: [String]
    let descriptions: [String]
    let genres: [String]
    let styles: [String]
    
    @Published private(set) var tracklist: [RealmTrackCodable] = []

    init(from release: RealmReleaseCodable) {
        self.id = release.instanceId
        self.title = release.basicInformation.title
        self.year = release.basicInformation.year
        self.artists = Array(release.basicInformation.artists)
        self.coverImage = release.basicInformation.coverImage
        self.resourceURL = release.basicInformation.resourceURL
        
        self.genres = Array(release.basicInformation.genres)
        self.styles = Array(release.basicInformation.styles)
        self.formats = release.basicInformation.formats.map { $0.name }
        self.descriptions = Array(release.basicInformation.formats.map { Array($0.descriptions) })
            .flatMap { $0 }
    }
    
    func getDetail() async {
        if let details = await DCManager.shared.getDetail(for: resourceURL) {
            DispatchQueue.main.async {
                self.tracklist = Array(details.tracklist)
            }
        }
    }
    
}
