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
        case title, year, artists, genres, styles
        case coverImage = "cover_image"
    }

}

class RealmArtistCodable: Object, Codable {
    @Persisted private(set) var name: String
}

class RealmFormatCodable: Object, Codable {
    @Persisted private(set) var name: String
    @Persisted private(set) var descriptions: RealmSwift.List<String>
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

enum FilterCategory: String {
    case genres, styles, formats, descriptions
}

struct FilterOption: Hashable {
    
    let id: UUID = UUID()
    
    let title: String
    var selected: Bool = false
    
}

class RealmFilterController: ObservableObject {
    
    init(releases: [RealmReleaseCodable]) {
        
    }
    
    static func getFilters(for releases: [RealmReleaseCodable]) -> [FilterCategory:[FilterOption]] {
        var options:[FilterCategory:[FilterOption]] = [:]
        
        //Genres
        options[.genres] = releases
            .map { $0.basicInformation.genres } // [[String]]
            .flatMap { $0 } // [String]
            .uniques
            .sorted(by: { $0 < $1 })
            .map { FilterOption(title: $0) }
        
        //Styles/Subgenres
        options[.styles] = releases
            .map { $0.basicInformation.styles } // [[String]]
            .flatMap { $0 } // [String]
            .uniques
            .sorted(by: { $0 < $1 })
            .map { FilterOption(title: $0) }

        //Formats
        let formats = releases
            .map { $0.basicInformation.formats }
            .flatMap { $0 }
        
//        options[.formats] = releases
//            .map { $0.basicInformation.formats } // [[String]]
//            .flatMap { $0 } // [String]
//            .uniques
//            .sorted(by: { $0 < $1 })
//            .map { FilterOption(title: $0) }

//        //Format Descriptions
//        options[.descriptions] = releases
//            .map { $0.basicInformation.formats.descriptions } // [[String]]
//            .flatMap { $0 } // [String]
//            .uniques
//            .sorted(by: { $0 < $1 })
//            .map { FilterOption(title: $0) }


        return options
    }

    
}

struct RealmListView: View {
    
    @ObservedResults(RealmReleaseCodable.self) var releases
    let appViewModel: AppViewModel = .shared
    @State private var showingFilters: Bool = false
    let filterController = FilterController(releases: [])
    
    var body: some View {
        NavigationView {
            conditionalView
                .navigationTitle("Collection")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button("Log Out", role: .destructive, action: appViewModel.logOut)
                            Button("Delete Collection", role: .destructive, action: deleteReleases)
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Filter") {
                            showingFilters = true
                        }
                    }
                }
        }
        .sheet(isPresented: $showingFilters) {
            FilterView(filterController: filterController)
        }

    }
    
    var conditionalView: some View {
        if releases.isEmpty {
            return AnyView(Button("Get Releases", action: getReleases))
        } else {
            return AnyView(SwiftUI.List {
//                let predicate = NSPredicate(format: "ANY basicInformation.artists.name CONTAINS[dc] %@", "bad snacks")
//                let releases = releases.filter(predicate)
                ForEach(releases) { release in
                    Text(release.basicInformation.title)
                }
            })
        }
    }
    
    func deleteReleases() {
        RealmManager.shared.deleteAllReleases()
    }
    
    func getReleases() {
        DCManager.shared.getAllReleasesForUser { releases in
            RealmManager.shared.update(with: releases)
        }
    }
    
    func logOut() {
        RealmManager.shared.deleteAllReleases()
        appViewModel.logOut()
    }
    
}
