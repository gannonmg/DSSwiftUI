//
//  Design+Constants.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/14/22.
//

import SwiftUI

extension Color {
    static let vsPrimaryDark: Color = Color("PrimaryDark")
    static let vsAccent: Color = Color("Accent")
    static let vsBackground: Color = Color("Background")
    static let vsShadowColor: Color = .black.opacity(0.25)
    static let vsDarkText: Color = Color("DarkText")
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
