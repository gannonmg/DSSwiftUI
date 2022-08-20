//
//  ReleaseListHeaderView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/14/22.
//

import SwiftUI

struct ReleaseListHeaderView: View {

    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var viewModel: ReleaseListViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Vinyl Space")
                    .appFont(.lobster, size: 28)
                    .foregroundColor(.white)
                    .vsShadow(verticalSpread: 2)
                
                Spacer()
                
                Menu {
                    Button("Log Out", role: .destructive,
                           action: appViewModel.logOutAll)
                    Button("Delete Collection", role: .destructive,
                           action: RealmManager.shared.deleteAllReleases)
                    lastFmButton
                } label: {
                    Image.settingsIcon
                        .foregroundColor(.white)
                }
                .testIdentifier(ReleaseListIdentifier.settingsButton)
                
            }
            
            ButtonedSearchField()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background {
            Rectangle()
                .ignoresSafeArea()
                .foregroundColor(.vsPrimaryDark)
        }
    }
    
    var lastFmButton: some View {
        if appViewModel.lastFmKey != nil {
            return Button("Last.FM Logout", role: .destructive) {
                appViewModel.logOutLastFm()
            }
        } else {
            return Button("Last.FM Login") {
                appViewModel.showingLastFmLogin = true
            }
        }
    }
}

struct ButtonedSearchField: View {
    @EnvironmentObject private var viewModel: ReleaseListViewModel

    var body: some View {
        HStack {
            Image.searchIcon
                .foregroundColor(.white)
            
            TextField("", text: $viewModel.searchQuery)
                .submitLabel(.done)
                .appFont(.robotoRegular, size: 16)
                .foregroundColor(.white)
                .placeholder(when: viewModel.searchQuery.isEmpty) {
                    Text("Search")
                        .appFont(.robotoRegular, size: 16)
                        .foregroundColor(.white.opacity(0.6))
                }
            
            Button {
                viewModel.showingFilters = true
            } label: {
                let filtersOn: Bool = !viewModel.filterController.selectedFilters.isEmpty
                let iconColor: Color = filtersOn ? .white : .white.opacity(0.5)
                Image.filterIcon
                    .foregroundColor(iconColor)
            }

        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background {
            Color.vsBackground
                .cornerRadius(10)
        }
    }
}

struct ReleaseListHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ReleaseListHeaderView()
            Color.gray
                .layoutPriority(1)
        }
    }
}
