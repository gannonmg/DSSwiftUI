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
    var id: Int { get }
}

struct ReleaseListItemView: View {
    let release: ListItemDisplayable
    let onTap: StandardAction
    
    var body: some View {
        ZStack(alignment: .leading) {
            listenButton
            itemView
                .onTapGesture(perform: onTap)
        }
    }
    
    var itemView: some View {
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
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.vsPrimaryDark)
                .vsShadow()
        }
        .offset(dragOffset)
        .gesture(dragGesture)
    }
    
    var listenButton: some View {
        VSSecondaryButton("Listen", image: Image(systemName: "headphones"), action: listenAction)
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: ListenWidthPreferenceKey.self,
                    value: geometry.size.width
                )
            })
            .onPreferenceChange(ListenWidthPreferenceKey.self) { newWidth in
                guard floor(newWidth) != buttonWidth else { return }
                self.buttonWidth = floor(newWidth)
            }
            .scaleEffect(buttonScale)
            .offset(buttonOffset)
            .padding(.horizontal, buttonPadding)
    }
    
    // MARK: Drag Gesture & List Button
    @State private var oldOffset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var buttonWidth: CGFloat = 0
    @State private var overDragged: Bool = false

    let buttonPadding: CGFloat = 16
    var buttonAreaWidth: CGFloat {
        return buttonWidth + (2 * buttonPadding)
    }
    
    var buttonScale: CGFloat {
        guard dragOffset.width > buttonAreaWidth else { return 1 }
        return dragOffset.width / buttonAreaWidth
    }
    
    var buttonOffset: CGSize {
        guard dragOffset.width > buttonAreaWidth else { return .zero }
        let xOffset: CGFloat = (dragOffset.width - buttonAreaWidth) / 2
        return CGSize(width: xOffset, height: 0)
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onChanged { value in
                // Old offset will either be 0 or the button area width.
                // Add to current translation to get correct offset
                let totalXOffset: CGFloat = oldOffset.width + value.translation.width
                let newXOffset: CGFloat = max(0, totalXOffset)
                
                if newXOffset > (buttonAreaWidth * 2) {
                    // The gesture is "over dragged."
                    // Check to make sure not yet set so impact is only generated once
                    if !overDragged {
                        overDragged = true
                        UIImpactFeedbackGenerator.init(style: .heavy).impactOccurred()
                    }
                } else {
                    // Again, check to make sure we are no re-triggering impact.
                    if overDragged {
                        overDragged = false
                        UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
                    }
                }
                
                withAnimation(.easeInOut(duration: 0.15)) {
                    dragOffset = CGSize(width: newXOffset, height: 0)
                }
            }
            .onEnded { value in
                // If drag released and currently over dragged, scrobble the album and return to default state
                if overDragged {
                    listenAction()
                    return
                }
                
                // Otherwise, handle end of drag
                withAnimation(.spring()) {
                    // If dragged past button but not over dragged, keep button revealed
                    // Else, hide listen button
                    let finalOffset: CGFloat = max(value.predictedEndTranslation.width, dragOffset.width)
                    if finalOffset > buttonAreaWidth {
                        let newOffset: CGSize = .init(width: buttonAreaWidth, height: 0)
                        oldOffset = newOffset
                        dragOffset = newOffset
                    } else {
                        oldOffset = .zero
                        dragOffset = .zero
                    }
                }
            }
    }
    
    struct ListenWidthPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat,
                           nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    
    /// Call on button tap or overdrag.
    func listenAction() {
        print("Tapped listen on \(release.title)")
        resetDrag()
    }
    
    func listenTo(_ release: ListItemDisplayable) {
        print("Tapped listen on \(release.title)")
        resetDrag()
    }
    
    func resetDrag() {
        withAnimation(.spring()) {
            overDragged = false
            oldOffset = .zero
            dragOffset = .zero
        }
    }
}

// MARK: - Canvas
#if DEBUG
struct CanvasListItem: ListItemDisplayable {
    let thumbnailImage: String
    let title: String
    let artistList: String
    let id: Int
}
#endif

struct ReleaseListItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            let listItem: CanvasListItem = .init(
                thumbnailImage: "",
                title: "Circles",
                artistList: "Mac Miller",
                id: 1
            )
            ReleaseListItemView(release: listItem, onTap: {})
                .height(105)
            Spacer()
        }
        .padding()
    }
}
