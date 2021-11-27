//
//  RealmModels.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/25/21.
//

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

}

class RealmBasicInformation: Object, Codable {
    
    @Persisted private(set) var title: String
    @Persisted private(set) var year: Int
    @Persisted private(set) var artists: RealmSwift.List<RealmArtistCodable>
    @Persisted private(set) var coverImage: String
    @Persisted private(set) var formats: RealmSwift.List<RealmFormatCodable>
    @Persisted private(set) var genres: RealmSwift.List<String>
    @Persisted private(set) var styles: RealmSwift.List<String>

    enum CodingKeys: String, CodingKey {
        case title, year, artists, genres, styles, formats
        case coverImage = "cover_image"
    }

}

class RealmArtistCodable: Object, Codable {
    @Persisted private(set) var name: String
}

class RealmFormatCodable: Object, Codable {
    
    @Persisted private(set) var name: String
    @Persisted private(set) var descriptions: RealmSwift.List<String>
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.descriptions = try container.decodeIfPresent(List<String>.self, forKey: .descriptions) ?? List<String>()
    }
}
