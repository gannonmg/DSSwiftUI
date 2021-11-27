//
//  RealmFilterController.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/25/21.
//

import RealmSwift
import SwiftUI

enum FilterCategory: String, CaseIterable {
    
    case genres, styles, formats, descriptions
    
//      let predicate = NSPredicate(format: "ANY basicInformation.artists.name CONTAINS[dc] %@", "bad snacks")
    var keyPath: String {
        switch self {
        case .genres: return "basicInformation.genres"
        case .styles: return "basicInformation.styles"
        case .formats: return "basicInformation.formats.name"
        case .descriptions: return "basicInformation.formats.descriptions"
        }
    }
    
}

struct FilterOption: Hashable {
    let id: UUID = UUID()
    let title: String
    var selected: Bool = false
}

class RealmFilterController: ObservableObject {
    
    @Published var predicate: NSPredicate?
    @Published var exclusiveFilter: Bool = true {
        didSet { setPredicate() }
    }
    @Published var filterOptions:[FilterCategory:[FilterOption]] {
        didSet { setPredicate() }
    }
    
    init(releases: [RealmReleaseCodable]) {
        self.filterOptions = RealmFilterController.getFilters(for: releases)
    }
    
}

//MARK: - Computed Properties
extension RealmFilterController {
    
    var genres:[FilterOption] { filterOptions[.genres] ?? [] }
    var styles:[FilterOption] { filterOptions[.styles] ?? [] }
    var formats:[FilterOption] { filterOptions[.formats] ?? [] }
    var descriptions:[FilterOption] { filterOptions[.descriptions] ?? [] }

    var categories:[String] {
        return filterOptions.keys
            .map { $0.rawValue.capitalized }
            .sorted { $0 < $1 }
    }

    var selectedFilters:[FilterOption] {
        return allFilterOptions.selected
    }

    var allFilterOptions:[FilterOption] {
        return filterOptions.values.flatMap { $0 }
    }
    
}

//MARK: - Filter functions
extension RealmFilterController {
    
    func tappedOption(_ tappedOption: FilterOption) {
        for key in filterOptions.keys {
            for i in 0..<filterOptions[key]!.count {
                guard filterOptions[key]![i].id == tappedOption.id else { continue }
                filterOptions[key]![i].selected.toggle()
            }
        }
    }

    func removeOption(_ tappedOption: FilterOption) {
        for key in filterOptions.keys {
            for i in 0..<filterOptions[key]!.count {
                guard filterOptions[key]![i].id == tappedOption.id else { continue }
                filterOptions[key]![i].selected = false
            }
        }
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
        
        options[.formats] = formats
            .map { $0.name }
            .uniques
            .sorted(by: { $0 < $1 })
            .map { FilterOption(title: $0) }

        //Format Descriptions
        options[.descriptions] = formats
            .map { $0.descriptions }
            .flatMap { $0 }
            .uniques
            .sorted(by: { $0 < $1 })
            .map { FilterOption(title: $0) }

        return options
    }
    
    func setPredicate() {
        
        var predicates:[String] = []

        for category in FilterCategory.allCases {
            let selected = filterOptions[category]?.selected ?? []
            for option in selected {
                predicates.append("ANY \(category.keyPath) CONTAINS[dc] '\(option.title)'")
            }
        }
        
        if predicates.isEmpty {
            predicate = nil
        } else {
            let conjunction = exclusiveFilter ? "AND" : "OR"
            let predicateString = predicates.joined(separator: " \(conjunction) ")
            print("Predicate string is \(predicateString)")
            predicate = NSPredicate(format: predicateString)
        }
    }
    
}

extension Array where Element == FilterOption {
    
    var selected:[FilterOption] { self.filter { $0.selected } }
    
}
