//
//  ReleaseListItemView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/14/22.
//

import SwiftUI

protocol ListItemDisplayable {
    var thumbnailImage: String { get }
    var title: String { get }
    var artistList: String { get }
}

struct ReleaseListItemView: View {
    let release: ListItemDisplayable

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.vsPrimaryDark)
                .shadow(
                    color: .vsShadowColor,
                    radius: 4,
                    x: 4, y: 4
                )

            HStack(alignment: .top, spacing: 10) {
                RemoteImageView(
                    url: URL(string: release.thumbnailImage),
                    placeholder: UIImage(systemName: "photo")!
                )
                .height(80)
                .width(80)
                
                VStack(alignment: .leading) {
                    Text(release.title)
                        .appFont(.robotoMedium, size: 18)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    Text(release.artistList)
                        .appFont(.robotoRegular, size: 14)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(12)
        }
    }
    
}

// MARK: - Canvas
#if DEBUG
struct CanvasListItem: ListItemDisplayable {
    var thumbnailImage: String
    var title: String
    var artistList: String
}
#endif

struct ReleaseListItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            let listItem: CanvasListItem = .init(
                thumbnailImage: "",
                title: "Circles",
                artistList: "Mac Miller"
            )
            ReleaseListItemView(release: listItem)
                .height(105)
            Spacer()
        }
        .padding()
    }
}
