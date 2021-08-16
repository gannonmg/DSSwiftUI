//
//  FilterController.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/8/21.
//

import Foundation

enum FilterCategory: String {
    case genres, styles, formats, descriptions
}

struct FilterOption: Hashable {
    
    let id:UUID = UUID()
    
    let title: String
    var selected: Bool = false
    
}

class FilterController: ObservableObject {
    
    var unfilteredReleases:[ReleaseViewModel]
    
    var searchQuery:String = "" {
        didSet {
            self.setFilteredReleases()
        }
    }
    
    @Published var filteredReleases:[ReleaseViewModel]
    @Published var filterOptions:[FilterCategory:[FilterOption]] {
        didSet {
            self.setFilteredReleases()
        }
    }
    
    @Published var exclusiveFilter: Bool = true {
        didSet {
            self.setFilteredReleases()
        }
    }
    
    var categories:[String] {
        return filterOptions.keys
            .map { $0.rawValue.capitalized }
            .sorted { $0 < $1 }
    }
    
    init(releases: [ReleaseViewModel]) {
        self.unfilteredReleases = releases
        self.filteredReleases = releases
        self.filterOptions = FilterController.getFilters(for: releases)
    }
    
    static func getFilters(for releases: [ReleaseViewModel]) -> [FilterCategory:[FilterOption]] {
        var options:[FilterCategory:[FilterOption]] = [:]
        
        //Genres
        options[.genres] = releases
            .map { $0.genres } // [[String]]
            .flatMap { $0 } // [String]
            .uniques
            .sorted(by: { $0 < $1 })
            .map { FilterOption(title: $0) }
        
        //Styles/Subgenres
        options[.styles] = releases
            .map { $0.styles } // [[String]]
            .flatMap { $0 } // [String]
            .uniques
            .sorted(by: { $0 < $1 })
            .map { FilterOption(title: $0) }

        //Formats
        options[.formats] = releases
            .map { $0.formats } // [[String]]
            .flatMap { $0 } // [String]
            .uniques
            .sorted(by: { $0 < $1 })
            .map { FilterOption(title: $0) }

        //Format Descriptions
        options[.descriptions] = releases
            .map { $0.descriptions } // [[String]]
            .flatMap { $0 } // [String]
            .uniques
            .sorted(by: { $0 < $1 })
            .map { FilterOption(title: $0) }


        return options
    }
    
    var allFilterOptions:[FilterOption] {
        return filterOptions.values.flatMap { $0 }
    }
    
    var selectedFilters:[FilterOption] {
        return allFilterOptions.filter { $0.selected }
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
    
    func setFilteredReleases() {
        
        //Trim the search query to make sure it's not just whitespace
        let searchQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //Make sure we have filters selected
        guard selectedFilters.count > 0 || searchQuery != "" else {
            self.filteredReleases = unfilteredReleases
            return
        }
        
        var newlyFilteredReleases:[ReleaseViewModel] = unfilteredReleases
        
        //Filter by query
        if searchQuery != "" {
            let ssMatcher = SmartSearchMatcher(searchString: searchQuery)
            newlyFilteredReleases = newlyFilteredReleases.filter { release in
                let releaseString = release.title + " " + release.artistList
                return ssMatcher.matches(releaseString)
            }
        }

        //Filter styles
        if selectedFilters.count > 0 {
            newlyFilteredReleases = applyFilters(to: newlyFilteredReleases)
        }
        
        print("filtered releases count is \(newlyFilteredReleases.count)")
        self.filteredReleases = newlyFilteredReleases
    }
    
    func applyFilters(to  releases: [ReleaseViewModel]) -> [ReleaseViewModel] {
        
        let descriptions = filterOptions[.descriptions]!
            .filter { $0.selected }
            .map { $0.title.lowercased() }

        let formats = filterOptions[.formats]!
            .filter { $0.selected }
            .map { $0.title.lowercased() }

        let genres = filterOptions[.genres]!
            .filter { $0.selected }
            .map { $0.title.lowercased() }
        
        let styles = filterOptions[.styles]!
            .filter { $0.selected }
            .map { $0.title.lowercased() }

        if exclusiveFilter {
            return releases.filter { release in
                let containsAll =
                    release.styles.contains(array: styles) &&
                    release.descriptions.contains(array: descriptions) &&
                    release.genres.contains(array: genres) &&
                    release.formats.contains(array: formats)
                
                return containsAll
            }
        } else {
            return releases.filter { release in
                let containsMatch =
                    styles.containsMatch(from: release.styles) ||
                    descriptions.containsMatch(from: release.descriptions) ||
                    genres.containsMatch(from: release.genres) ||
                    formats.containsMatch(from: release.formats)
                
                return containsMatch
            }
        }
    }
    
}
