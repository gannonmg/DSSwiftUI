//
//  RealmListView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/10/21.
//

import SwiftUI

/**
 This view has some programming concessions...
 First, I tend to avoid `List` since it requires you to remove some of Apple's opinionating design (see listRowSeparator and listRowBackground usage)
    However, in this case I need it to gain access to the `.refreshable` modifier.
 Then, I need to add a LazyVStack inside of it to regain control on some of the padding (was too close to the top and bottom edges before)
 Maybe some day Apple will give open up `.refreshable` to ScrollViews. Until then...
 */
struct ReleaseListView: View {
    
    @EnvironmentObject var viewModel: ReleaseListViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    
    var body: some View {
        // Using List to take advantage of .refreshable modifier
        List {
            // LazyVStack is a hacky workaround to gain control over the vertical padding
            LazyVStack {
                ForEach(viewModel.releases) { release in
                    ReleaseListItemView(release: release)
                        .onTapGesture {
                            viewModel.setSelectedRelease(release)
                        }
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .padding(.top, 4)
            .padding(.bottom, 40)
        }
        .listStyle(.plain)
        .refreshable { refresh() }
        .background(Color.vsBackground)
        .testIdentifier(ReleaseListIdentifier.releaseList)
    }
    
    func refresh() {
        do {
            try viewModel.getRemoteReleases()
        } catch {
            errorHandling.handle(error: error)
        }
    }
}
