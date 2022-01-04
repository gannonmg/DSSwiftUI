//
//  RealmFilterController.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/25/21.
//

import SwiftUI

enum FilterCategory: String, CaseIterable {
    
    case genres, styles, formats, descriptions
    
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

class FilterViewModel: ObservableObject {
    
    @Published private(set) var predicate: NSPredicate?
    
    @Published var exclusiveFilter: Bool = true {
        didSet { setPredicate() }
    }
    
    @Published private(set) var filterOptions: [FilterCategory: [FilterOption]] {
        didSet { setPredicate() }
    }
    
    init(releases: [ReleaseViewModel]) {
        self.filterOptions = FilterViewModel.getFilters(for: releases)
    }
    
}

// MARK: - Computed Properties
extension FilterViewModel {
    
    var genres: [FilterOption] { filterOptions[.genres] ?? [] }
    var styles: [FilterOption] { filterOptions[.styles] ?? [] }
    var formats: [FilterOption] { filterOptions[.formats] ?? [] }
    var descriptions: [FilterOption] { filterOptions[.descriptions] ?? [] }

    var categories: [String] {
        return filterOptions.keys
            .map { $0.rawValue.capitalized }
            .sorted { $0 < $1 }
    }

    var selectedFilters: [FilterOption] {
        return allFilterOptions.selected
    }

    var allFilterOptions: [FilterOption] {
        return filterOptions.values.flatMap { $0 }
    }
    
}

// MARK: - Filter functions
extension FilterViewModel {
    
    func tappedOption(_ tappedOption: FilterOption) {
        for key in filterOptions.keys {
            let count = filterOptions[key]?.count ?? 0
            for index in 0..<count {
                guard filterOptions[key]?[index].id == tappedOption.id else { continue }
                filterOptions[key]?[index].selected.toggle()
            }
        }
    }

    func removeOption(_ tappedOption: FilterOption) {
        for key in filterOptions.keys {
            let count = filterOptions[key]?.count ?? 0
            for index in 0..<count {
                guard filterOptions[key]?[index].id == tappedOption.id else { continue }
                filterOptions[key]?[index].selected = false
            }
        }
    }

    static func getFilters(for releases: [ReleaseViewModel]) -> [FilterCategory: [FilterOption]] {
        var options: [FilterCategory: [FilterOption]] = [:]
        
        // Genres
        options[.genres] = releases
            .map { $0.genres } // [[String]]
            .flatMap { $0 } // [String]
            .uniques
            .sorted(by: { $0 < $1 })
            .map { FilterOption(title: $0) }
        
        // Styles/Subgenres
        options[.styles] = releases
            .map { $0.styles } // [[String]]
            .flatMap { $0 } // [String]
            .uniques
            .sorted(by: { $0 < $1 })
            .map { FilterOption(title: $0) }

        // Formats
        options[.formats] = releases
            .map { $0.formats }
            .flatMap { $0 } // [String]
            .uniques
            .sorted(by: { $0 < $1 })
            .map { FilterOption(title: $0) }

        // Descriptions
        options[.descriptions] = releases
            .map { $0.descriptions }
            .flatMap { $0 }
            .uniques
            .sorted(by: { $0 < $1 })
            .map { FilterOption(title: $0) }

        return options
    }
    
    func updateFilters(for newReleases: [ReleaseViewModel]) {
        
        // Get the filters for the releases like normal
        var newFilters = FilterViewModel.getFilters(for: newReleases)
        
        // Search for filter matches in the old filters and update selected status
        for key in newFilters.keys {
            guard let options = newFilters[key] else { continue }
            for index in 0..<options.count {
                guard let match = filterOptions[key]?.first(where: { options[index].title == $0.title }) else { continue }
                newFilters[key]?[index].selected = match.selected
            }
        }
        
        // Assign our new filters
        self.filterOptions = newFilters
    }
    
    func setPredicate() {
        
        var predicates: [String] = []

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
            predicate = NSPredicate(format: predicateString)
        }
    }
    
    func turnOffAllFilters() {
        
        var freshFilterOptions: [FilterCategory: [FilterOption]] = [:]
        
        for category in FilterCategory.allCases {
            for option in filterOptions[category] ?? [] {
                let freshOption = FilterOption(title: option.title)
                if freshFilterOptions[category] == nil {
                    freshFilterOptions[category] = [freshOption]
                } else {
                    freshFilterOptions[category]?.append(freshOption)
                }
            }
        }

        self.exclusiveFilter = true
        self.filterOptions = freshFilterOptions
        
    }
    
}

extension Array where Element == FilterOption {
    
    var selected: [FilterOption] { self.filter { $0.selected } }
    
}
