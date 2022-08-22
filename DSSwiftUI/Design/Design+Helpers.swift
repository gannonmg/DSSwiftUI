//
//  Design+Helpers.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/20/22.
//

import SwiftUI

extension Text {
    func appFont(_ appFont: AppFont, size: CGFloat) -> Text {
        let uiFont: UIFont = UIFont(name: appFont.name, size: size)!
        let font: Font = .init(uiFont)
        return self.font(font)
    }
}

extension View {
    func appFont(_ appFont: AppFont, size: CGFloat) -> some View {
        let uiFont: UIFont = UIFont(name: appFont.name, size: size)!
        let font: Font = .init(uiFont)
        return self.font(font)
    }
}

extension View {
    func vsShadow(verticalSpread: CGFloat = 4) -> some View {
        return self.shadow(
            color: .vsShadowColor,
            radius: verticalSpread,
            x: verticalSpread * 3/4,
            y: verticalSpread
        )
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
