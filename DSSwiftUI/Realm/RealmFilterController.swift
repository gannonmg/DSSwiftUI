//
//  RealmFilterController.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/25/21.
//

import RealmSwift
import SwiftUI

enum FilterCategory: String {
    case genres, styles, formats, descriptions
}

struct FilterOption: Hashable {
    
    let id: UUID = UUID()
    
    let title: String
    var selected: Bool = false
    
}

class RealmFilterController: ObservableObject {
    
    @Published var filterOptions:[FilterCategory:[FilterOption]]
    @Published var exclusiveFilter: Bool = true
    
    var categories:[String] {
        return filterOptions.keys
            .map { $0.rawValue.capitalized }
            .sorted { $0 < $1 }
    }

    var selectedFilters:[FilterOption] {
        return allFilterOptions.filter { $0.selected }
    }

    var allFilterOptions:[FilterOption] {
        return filterOptions.values.flatMap { $0 }
    }
    
    init(releases: [RealmReleaseCodable]) {
        self.filterOptions = RealmFilterController.getFilters(for: releases)
    }
    
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
    
}
