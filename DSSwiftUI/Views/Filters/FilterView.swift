//
//  FilterView.swift
//  DiscogsShuffle
//
//  Created by Matt Gannon on 6/3/21.
//

import SwiftUI

private let filtersHorizontalPadding: CGFloat = 20

struct FilterView: View {
    
    @EnvironmentObject var filterController: FilterViewModel
    @Environment(\.dismiss) var dismiss: DismissAction

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                VStack {
                    if !filterController.selectedFilters.isEmpty {
                        selectFiltersSection
                    }
                    categoryList
                    Spacer()
                    VSButton("Done", buttonStyle: .dark) {
                        dismiss()
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, filtersHorizontalPadding)
            }
            .navigationBarHidden(true)
            .background(Color.vsBackground)
        }
    }
    
    var headerView: some View {
        HStack {
            Text("Filters")
                .appFont(.robotoBold, size: 28)
                .foregroundColor(.white)
            Spacer()
            VSSecondaryButton("Clear", action: filterController.turnOffAllFilters)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, minHeight: 75, idealHeight: 75)
        .background {
            Color.vsPrimaryDark
                .vsShadow()
        }
    }
    
    var selectFiltersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current")
                .appFont(.robotoBold, size: 20)
                .foregroundColor(.white)
            SelectedFiltersView()
        }
    }
    
    var categoryList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .appFont(.robotoBold, size: 20)
                .foregroundColor(.white)
            VStack(spacing: 8) {
                FilterToggleView(option: $filterController.exclusiveFilter)
                
                ForEach(filterController.categories, id: \.self) { category in
                    let filterCategory: FilterCategory = FilterCategory(rawValue: category.lowercased())!
                    let destination: FilterSelectionView = .init(category: filterCategory)
                    
                    NavigationLink(
                        destination: destination,
                        tag: filterCategory,
                        selection: $filterController.filterDetail,
                        label: { FilterCategoryView(category: category) }
                    )
                }
            }
        }
    }
}

struct FilterToggleView: View {
    @Binding var option: Bool
    
    var body: some View {
        HStack {
            Text("Filter Exclusively")
                .appFont(.robotoMedium, size: 18)
                .foregroundColor(.vsDarkText)
            Spacer()
            Toggle("", isOn: $option)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, minHeight: 44, idealHeight: 44)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.white)
        }
    }
}

struct FilterCategoryView: View {
    let category: String
    
    var body: some View {
        HStack {
            Text(category)
                .appFont(.robotoMedium, size: 18)
                .foregroundColor(.vsDarkText)
            Spacer()
            Image.rightArrow
                .foregroundColor(.vsDarkText)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, minHeight: 44, idealHeight: 44)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.white)
                .vsShadow(verticalSpread: 2)
        }
    }
}

struct SelectedFiltersView: View {
    
    @EnvironmentObject private var filterController: FilterViewModel
    private let shadowBuffer: CGFloat = 8
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(filterController.selectedFilters) { option in
                    SelectedFilterView(title: option.title) {
                        withAnimation(.easeOut) {
                            filterController.removeOption(option)
                        }
                    }
                }
            }
            .padding(.horizontal, filtersHorizontalPadding)
            .padding(.bottom, shadowBuffer)
        }
        .padding(.horizontal, -filtersHorizontalPadding)
        .padding(.bottom, -shadowBuffer)
    }
    
    private struct SelectedFilterView: View {
        let title: String
        let action: StandardAction
        
        var body: some View {
            HStack {
                Button(action: action) {
                    Image.closeIcon.foregroundColor(.vsDarkText)
                }
                Text(title)
                    .appFont(.robotoMedium, size: 16)
                    .foregroundColor(.vsDarkText)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 32, idealHeight: 32)
            .background {
                Capsule()
                    .foregroundColor(.white)
                    .shadow(color: .vsShadowColor, radius: 3, x: 2, y: 2)
            }
        }
    }
}
