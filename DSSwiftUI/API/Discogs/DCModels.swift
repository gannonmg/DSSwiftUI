//
//  DCModels.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/31/21.
//


import Foundation

/*
// MARK: - CollectionReleasesResponse
struct CollectionReleasesResponse: Codable {
    let pagination: Pagination
    let releases: [DCRelease]
}

// MARK: - DCRelease
struct DCRelease: Codable, Hashable {
    
    let id, instanceID: Int
    let dateAdded: String
    let rating: Int
    let basicInformation: BasicInformation
    let folderID: Int
    let notes: [Note]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case instanceID = "instance_id"
        case dateAdded = "date_added"
        case rating
        case basicInformation = "basic_information"
        case folderID = "folder_id"
        case notes
    }
    
    //MARK: - Initializers
    ///Custom init to avoid having to create title and artist display each time they are used for a search. Could not use lazy var since Release is a struct and not a class
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.instanceID = try container.decode(Int.self, forKey: .instanceID)
        self.dateAdded = try container.decode(String.self, forKey: .dateAdded)
        self.rating = try container.decode(Int.self, forKey: .rating)
        self.basicInformation = try container.decode(BasicInformation.self, forKey: .basicInformation)
        self.folderID = try container.decode(Int.self, forKey: .folderID)
        self.notes = try? container.decode([Note].self, forKey: .notes)
    }
    
    ///Manual init for creating a test object to use with SwiftUI Canvas
    init(id: Int, instanceID: Int, dateAdded: String, rating: Int, basicInformation: BasicInformation, folderID: Int, notes: [Note]?) {
        self.id = id
        self.instanceID = instanceID
        self.dateAdded = dateAdded
        self.rating = rating
        self.basicInformation = basicInformation
        self.folderID = folderID
        self.notes = notes
    }
    
    //MARK: Release Hashable Conformance
    let uuid:UUID = UUID()
    static func == (lhs: DCRelease, rhs: DCRelease) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    //MARK: Testing/Development
    static var filterTestRelease:DCRelease {
        self.init(id: 0, instanceID: 0, dateAdded: "", rating: 5,
                  basicInformation: BasicInformation.init(id: 0, masterID: 0, masterURL: nil, resourceURL: "",
                                                          thumb: "", coverImage: "", title: "", year: 2020,
                                                          formats: [.init(name: "LP", qty: "1", text: nil, descriptions: ["box set", "deluxe"]),
                                                                    .init(name: "single", qty: "1", text: nil, descriptions: ["7", "45rpm"]),],
                                                          labels: [], artists: [],
                                                          genres: ["Rap", "Hip-Hop", "Country", "World", "Funk", "IDM"],
                                                          styles: ["Jazzy", "Lofi", "Chill", "Special", "Whatever", "Style!"]),
                  folderID: 0, notes: nil)
    }
    
}

// MARK: - BasicInformation
struct BasicInformation: Codable, Hashable {
    let id, masterID: Int
    let masterURL: String?
    let resourceURL: String
    let thumb, coverImage: String
    let title: String
    let year: Int
    let formats: [Format]
    let labels: [DCLabel]
    let artists: [Artist]
    let genres: [String]
    let styles: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case masterID = "master_id"
        case masterURL = "master_url"
        case resourceURL = "resource_url"
        case thumb
        case coverImage = "cover_image"
        case title, year, formats, labels, artists, genres, styles
    }
    
    //MARK: Basic Information Hashable Conformance
    let uuid:UUID = UUID()
    static func == (lhs: BasicInformation, rhs: BasicInformation) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
}

// MARK: - Artist
struct Artist: Codable, Hashable {
    let name: String
    let anv: String
    let join, role, tracks: String
    let id: Int
    let resourceURL: String
    
    enum CodingKeys: String, CodingKey {
        case name, anv, join, role, tracks, id
        case resourceURL = "resource_url"
    }
    
    //MARK: Artist Hashable Conformance
    let uuid:UUID = UUID()
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
}

// MARK: - Format
struct Format: Codable, Hashable {
    let name: String
    let qty: String
    let text: String?
    let descriptions: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, qty, text, descriptions
    }
    
    //MARK: Format Conformance
    let uuid:UUID = UUID()
    static func == (lhs: Format, rhs: Format) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
}

// MARK: - Label
struct DCLabel: Codable, Hashable {
    let name, entityType: String
    let entityTypeName: String
    let id: Int
    let resourceURL: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case entityType = "entity_type"
        case entityTypeName = "entity_type_name"
        case id
        case resourceURL = "resource_url"
    }
    
    //MARK: Label Hashable Conformance
    let uuid:UUID = UUID()
    static func == (lhs: DCLabel, rhs: DCLabel) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
}

// MARK: - Note
struct Note: Codable, Hashable {
    let fieldID: Int
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case fieldID = "field_id"
        case value
    }
    
    //MARK: Note Hashable Conformance
    let uuid:UUID = UUID()
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
}

//MARK: - DCRelease Detail -------------
// MARK: - DCReleaseDetail
struct DCReleaseDetail: Codable {
    let id: Int
    let status: String
    let year: Int
    let resourceURL, uri: String
    let artists: [Artist]
    let artistsSort: String
    let labels, series, companies: [Company]
    let formats: [Format]
    let dataQuality: String
    let community: Community
    let formatQuantity: Int
    let dateAdded, dateChanged: String
    let numForSale: Int
    let masterID: Int?
    let lowestPrice: Double?
    let masterURL: String?
    let title, country: String
    let released: String?
    let notes: String?
    let releasedFormatted: String?
    let identifiers: [DCIdentifier]
    let videos: [DCVideo]?
    let genres: [String]
    let styles: [String]?
    let tracklist: [DCTrack]
    let extraArtists: [Artist]?
    let images: [DCImage]
    let thumb: String
    let estimatedWeight: Int
    let blockedFromSale: Bool

    enum CodingKeys: String, CodingKey {
        case id, status, year
        case resourceURL = "resource_url"
        case uri, artists
        case artistsSort = "artists_sort"
        case labels, series, companies, formats
        case dataQuality = "data_quality"
        case community
        case formatQuantity = "format_quantity"
        case dateAdded = "date_added"
        case dateChanged = "date_changed"
        case numForSale = "num_for_sale"
        case lowestPrice = "lowest_price"
        case masterID = "master_id"
        case masterURL = "master_url"
        case title, country, released, notes
        case releasedFormatted = "released_formatted"
        case identifiers, videos, genres, styles, tracklist, images, thumb
        case extraArtists = "extraartists"
        case estimatedWeight = "estimated_weight"
        case blockedFromSale = "blocked_from_sale"
    }
}

// MARK: - Community
struct Community: Codable {
    let have, want: Int
    let rating: Rating
    let submitter: Submitter
    let contributors: [Submitter]
    let dataQuality, status: String

    enum CodingKeys: String, CodingKey {
        case have, want, rating, submitter, contributors
        case dataQuality = "data_quality"
        case status
    }
}

// MARK: - Submitter
struct Submitter: Codable {
    let username: String
    let resourceURL: String

    enum CodingKeys: String, CodingKey {
        case username
        case resourceURL = "resource_url"
    }
}

// MARK: - Rating
struct Rating: Codable {
    let count: Int
    let average: Double
}

// MARK: - Company
struct Company: Codable {
    let name: String
    let entityType, entityTypeName: String
    let id: Int
    let resourceURL: String

    enum CodingKeys: String, CodingKey {
        case name
        case entityType = "entity_type"
        case entityTypeName = "entity_type_name"
        case id
        case resourceURL = "resource_url"
    }
}

// MARK: - Identifier
struct DCIdentifier: Codable {
    let type, value: String
    let identifierDescription: String?

    enum CodingKeys: String, CodingKey {
        case type, value
        case identifierDescription = "description"
    }
}

// MARK: - DCImage
struct DCImage: Codable {
    let type: DCImageType
    let uri, resourceURL, uri150: String
    let width, height: Int

    enum CodingKeys: String, CodingKey {
        case type, uri
        case resourceURL = "resource_url"
        case uri150, width, height
    }
}

enum DCImageType: String, Codable {
    case primary = "primary"
    case secondary = "secondary"
}

// MARK: - Tracklist
struct DCTrack: Codable, Hashable {
    let position, type, title: String
    let extraartists: [Artist]?
    let duration: String

    enum CodingKeys: String, CodingKey {
        case position
        case type = "type_"
        case title, extraartists, duration
    }
    
}

// MARK: - Video
struct DCVideo: Codable {
    let uri: String
    let title, videoDescription: String
    let duration: Int
    let embed: Bool

    enum CodingKeys: String, CodingKey {
        case uri, title
        case videoDescription = "description"
        case duration, embed
    }
}

*/
