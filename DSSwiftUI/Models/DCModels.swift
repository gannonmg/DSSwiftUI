//
//  DCModels.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/25/21.
//

import Combine
import Foundation
import RealmSwift

struct CollectionReleasesResponse: Codable {
    let pagination: Pagination
    let releases: [DCReleaseModel]
}

// MARK: - Errors
enum DCError: Error {
    case releaseFailure
    case releaseDetailFailure
}

// MARK: - DCUser
struct DCUser: Codable {
    let id: Int
    let username: String
    let resourseUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, username
        case resourseUrl = "resource_url"
    }
    
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

class DCReleaseModel: Object, ObjectKeyIdentifiable, Codable {
    
    override static func primaryKey() -> String? {
        return "instanceId"
    }

    /// The unique identifier release for this album in the collection. Two identical albums in a collection will have different instanceIds.
    @Persisted private(set) var id: Int
    @Persisted private(set) var instanceId: Int
    @Persisted private(set) var basicInformation: DCBasicInformationModel!
    
    enum CodingKeys: String, CodingKey {
        case id,
             instanceId = "instance_id",
             basicInformation = "basic_information"
    }
    
    // Convenience
    var tracks: [DCTrackModel] { self.basicInformation.tracks ?? [] }

}

class DCBasicInformationModel: Object, Codable {
    
    @Persisted private(set) var title: String
    @Persisted private(set) var year: Int
    @Persisted private(set) var artists: List<DCArtistModel>
    @Persisted private(set) var coverImage: String
    @Persisted private(set) var thumbnailImage: String
    @Persisted private(set) var resourceURL: String
    @Persisted private(set) var formats: List<DCFormatModel>
    @Persisted private(set) var genres: List<String>
    @Persisted private(set) var styles: List<String>
    
    @Published private(set) var tracks: [DCTrackModel]? {
        didSet {
            print("Tracks changed")
        }
    }

    enum CodingKeys: String, CodingKey {
        case title, year, artists, genres, styles, formats
        case coverImage = "cover_image"
        case thumbnailImage = "thumb"
        case resourceURL = "resource_url"
    }

}

class DCArtistModel: Object, Codable {
    @Persisted private(set) var name: String
}

class DCFormatModel: Object, Codable {
    
    @Persisted private(set) var name: String
    @Persisted private(set) var descriptions: List<String>
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.descriptions = try container.decodeIfPresent(List<String>.self, forKey: .descriptions) ?? List<String>()
    }
}

class DCReleaseDetailModel: Object, Codable {
    
    override static func primaryKey() -> String? {
        return "id"
    }

    @Persisted private(set) var id: Int
    @Persisted private(set) var tracklist: List<DCTrackModel>

    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.tracklist = try container.decodeIfPresent(List<DCTrackModel>.self, forKey: .tracklist) ?? List<DCTrackModel>()
    }
    
}

class DCTrackModel: Object, Codable, Identifiable {
    
    let id = UUID()
    
    @Persisted private(set) var position: String
    @Persisted private(set) var type: String
    @Persisted private(set) var title: String
    @Persisted private(set) var duration: String
    @Persisted private(set) var extraArtists: List<DCArtistModel>
    
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
        self.extraArtists = try container.decodeIfPresent(List<DCArtistModel>.self, forKey: .extraArtists) ?? List<DCArtistModel>()
    }
    
}
