//
//  RealmListView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/10/21.
//

import SwiftUI

/**
 Ohhhh, this is a weird one!
 
 Anyone checking this out may be a bit confused on my use of this custom `Listable` enum/view
 I had two requirements for this page:
    1. I wanted to use `List`'s `.refreshable` modifier (home built solutions never felt quite like the OS standard)
    2. I needed better control over the top and bottom padding - by default, the top looked cramped, and the last listing was a bit obscured by the gradient and shuffle button
 
 To accomplish this, I needed to strip the `List` of it's default styling, and figure out how to add padding back in.
 Two issues:
    - Adding padding to the `List` caused it to clip content on scroll where padded
    - Adding padding to each item increased each item spacing, when I just needed the very start and last
 
 Here's where `Listable` comes in.
 `Listable` is quite simple - it's an `enum` that:
    - Is `Identifiable` (thus able to be iterated on in a `List` or `ForEach`
    - Conforms to `View` so I can use it inline when iterating
    - Takes either `height: CGFloat` or `release: ReleaseViewModel` (and tap action)  and returns either
        - A `Spacer` of said height
        - A `ReleaseListItemView` for the release
 
 All in all, this *may* be a bit overengineered. But it's not a huge amount of code,
 and generates clear and more obvious results than the solutions I was implementing before.
 */
struct ReleaseListView: View {
    
    @EnvironmentObject var viewModel: ReleaseListViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    
    var listItems: [Listable] {
        var items: [Listable] = []
        items.append(.spacer(height: 16))
        viewModel.releases.forEach { release in
            items.append(.releaseItem(
                release: release,
                action: { viewModel.setSelectedRelease(release) })
            )
        }
        items.append(.spacer(height: 60))
        return items
    }
    
    var body: some View {
        List(listItems) { item in
            item
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .environment(\.defaultMinListRowHeight, 0)
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

enum Listable: View, Identifiable {
    case spacer(id: UUID, height: CGFloat)
    case releaseItem(release: ReleaseViewModel, action: StandardAction)
    
    var id: Int {
        switch self {
        case .spacer(let id, _):
            return id.uuidString.hashValue
        case .releaseItem(let release, _):
            return release.id
        }
    }
    
    var body: some View {
        switch self {
        case .spacer(_, let height):
            Spacer().height(height)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        case .releaseItem(let release, let action):
            ReleaseListItemView(release: release, onTap: action)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 12, trailing: 16))
        }
    }
    
    static func spacer(height: CGFloat) -> Self {
        return .spacer(id: .init(), height: height)
    }
}

