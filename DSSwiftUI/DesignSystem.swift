//
//  DesignSystem.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/14/22.
//

import Foundation
import SwiftUI

extension Color {
    static let vsPrimaryDark: Color = Color("PrimaryDark")
    static let vsAccent: Color = Color("Accent")
    static let vsBackground: Color = Color("Background")
    static let vsShadowColor: Color = .black.opacity(0.25)
}

enum AppFont {
    case lobster
    case robotoRegular
    case robotoMedium
    case robotoBold

    var name: String {
        switch self {
        case .lobster: return "Lobster-Regular"
        case .robotoRegular: return "Roboto-Regular"
        case .robotoMedium: return "Roboto-Medium"
        case .robotoBold: return "Roboto-Bold"
        }
    }
}

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

extension Image {
    static let filterIcon: Image = .init("filters")
    static let searchIcon: Image = .init("search")
    static let settingsIcon: Image = .init("settings")
    static let shuffleIcon: Image = .init("shuffle")
    static let closeIcon: Image = .init("close")
    static let checkmarkIcon: Image = .init("checkmark")
    static let rightArrow: Image = .init("right arrow")
}

struct VSButton: View {
    enum VSButtonStyle {
        case light, dark
        
        var fontColor: Color { (self == .light) ? .vsPrimaryDark : .white }
        var backgroundColor: Color { (self == .light) ? .white : .vsPrimaryDark }
    }
    
    let title: String
    let buttonStyle: VSButtonStyle
    let action: StandardAction
    
    init(_ title: String, buttonStyle: VSButtonStyle, action: @escaping StandardAction) {
        self.title = title
        self.buttonStyle = buttonStyle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .appFont(.robotoBold, size: 20)
                .foregroundColor(buttonStyle.fontColor)
                .frame(maxWidth: .infinity, minHeight: 50, idealHeight: 50)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(buttonStyle.backgroundColor)
                    .vsShadow()
                }
        }
    }
}

struct VSSecondaryButton: View {
    let title: String
    let action: StandardAction
    
    init(_ title: String, action: @escaping StandardAction) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .appFont(.robotoMedium, size: 14)
                .foregroundColor(.vsPrimaryDark)
                .padding(.horizontal, 8)
                .frame(minWidth: 72, idealWidth: 72, minHeight: 28, idealHeight: 28)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(.white)
                    .vsShadow()
                }
        }
    }
}

extension View {
    func vsShadow(verticalSpread: CGFloat = 4) -> some View {
        return self.shadow(
            color: .vsShadowColor,
            radius: verticalSpread,
            x: 0, y: verticalSpread
        )
    }
}
