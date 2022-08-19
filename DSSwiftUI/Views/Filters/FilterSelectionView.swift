//
//  FilterOptionsView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/18/22.
//

import SwiftUI

struct FilterSelectionView: View {
    @EnvironmentObject private var filterController: FilterViewModel
    let category: FilterCategory
    
    var body: some View {
        VStack {
            SelectionHeaderView(category: category)
            ScrollView {
                VStack(spacing: 8) {
                    let categoryOptions: [FilterOption] = filterController.filterOptions[category] ?? []
                    ForEach(categoryOptions, id: \.self) { option in
                        FilterOptionView(option: option) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                filterController.tappedOption(option)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(category.rawValue.capitalized)
        .navigationBarHidden(true)
        .background(Color.vsBackground)
    }
}

struct SelectionHeaderView: View {
    @EnvironmentObject private var filterController: FilterViewModel
    let category: FilterCategory
    
    var body: some View {
        Text(category.rawValue.capitalized)
            .appFont(.robotoBold, size: 24)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 75, idealHeight: 75)
            .background {
                Color.vsPrimaryDark
                    .vsShadow()
            }
            .overlay(alignment: .leading) {
                Button {
                    filterController.filterDetail = nil
                } label: {
                    Image.rightArrow.rotationEffect(.degrees(180))
                        .foregroundColor(.white)
                }
                .padding(.leading, 12)
            }
    }
}

struct FilterOptionView: View {
    
    let option: FilterOption
    let action: StandardAction
    
    var body: some View {
        Button(action: action) {
            HStack {
                checkboxView
                Text(option.title)
                    .appFont(.robotoMedium, size: 18)
                    .foregroundColor(.vsPrimaryDark)
                Spacer()
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 44, idealHeight: 44)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(.white)
                    .vsShadow(verticalSpread: 2)
            }
        }
    }
    
    var checkboxView: some View {
        if option.selected {
            return AnyView(
                ZStack {
                    Circle()
                        .foregroundColor(.vsPrimaryDark)
                        .frame(width: 20, height: 20)
                    Image.checkmarkIcon
                        .foregroundColor(.white)
                }
            )
        } else {
            return AnyView(
                Circle()
                    .strokeBorder(Color.vsPrimaryDark, lineWidth: 1)
                    .foregroundColor(.clear)
                    .frame(width: 20, height: 20)
            )
        }
    }
}

// Allows use of back swipe gesture when navigation bar is hidden
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
