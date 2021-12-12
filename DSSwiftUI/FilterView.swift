//
//  FilterView.swift
//  DiscogsShuffle
//
//  Created by Matt Gannon on 6/3/21.
//

import SwiftUI

struct FilterView: View {
    
    @EnvironmentObject var filterController: RealmFilterController

    var body: some View {
        NavigationView {
            List {
                if filterController.selectedFilters.count > 0 {
                    SelectedFiltersView(filterController: filterController)
                }
                
                Toggle("Filter Exclusively", isOn: $filterController.exclusiveFilter)
                
                ForEach(filterController.categories, id: \.self) { category in
                    let filterCategory = FilterCategory(rawValue: category.lowercased())!
                    NavigationLink(destination: FilterSelectionView(category: filterCategory,
                                                                    filterController: filterController))
                    {
                        FilterCategoryView(title: category)
                    }
                }
            }
            .navigationTitle("Filters")
            .onAppear {
                UITableView.appearance().contentInset.top = 0
            }
        }
     }
}

struct SelectedFiltersView: View {
    
    @ObservedObject var filterController: RealmFilterController
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(filterController.selectedFilters, id: \.self) { option in
                    SelectedFilterView(title: option.title) {
                        withAnimation(.easeOut) {
                            filterController.removeOption(option)
                        }
                    }
                }
            }
        }
    }
    
    private struct SelectedFilterView: View {
        
        let title: String
        let action: StandardAction
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.black)
                HStack {
                    Button(action: action) {
                        Image(systemName: "x.circle")
                            .foregroundColor(.black)
                    }
                    Text(title)
                }
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .fixedSize()
            }
            .height(32)
        }
        
    }
    
}

struct FilterSelectionView: View {
    
    let category: FilterCategory
    @StateObject var filterController: RealmFilterController
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                let categoryOptions = filterController.filterOptions[category] ?? []
                ForEach(categoryOptions, id: \.self) { option in
                    VStack {
                        FilterOptionView(option: option) {
                            filterController.tappedOption(option)
                        }
                        Color.black
                            .opacity(0.2)
                            .frame(height: 1)
                            .padding(.horizontal, 8)
                    }
                }
            }
        }
        .navigationTitle(category.rawValue.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FilterOptionView: View {
    
    let option:FilterOption
    let action:(()->Void)
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            VStack(alignment: .center) {
                HStack {
                    Text(option.title)
                    Spacer()
                    let imageName = option.selected ? "checkmark.square.fill" : "checkmark.square"
                    Image(systemName: imageName)
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 40)
        })
    }
    
}

struct FilterCategoryView: View {
    
    let title:String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("(\(0))")
        }
    }
}
