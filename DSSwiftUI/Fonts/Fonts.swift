//
//  Fonts.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/17/21.
//

import SwiftUI

enum AppFont: String {
    case regular = "Roboto-Regular"
    case medium = "Roboto-Medium"
    case semiBold = "Roboto-SemiBold"
    case bold = "Roboto-Bold"

    var name: String {
        return self.rawValue
    }
}

struct FontDescription {
    let font: AppFont
    let size: CGFloat
    let style: UIFont.TextStyle
}

// TODO: Work with design team to find out what common font sizes we will be using, and name them clearly and appropriately
enum AppFonts {
    case title1
    case title2
    case title3
    case headline
    case headlineButton
    case body
    case bodyWith(size:CGFloat)
    case callout
    case calloutButton
    case calloutButton2
    case subheadline
    case footnote
    case caption1
    case caption2

}

extension AppFonts {
    private var fontDescription: FontDescription {
        switch self {
        case .title1:
            return FontDescription(font: .bold, size: 28, style: .title1)
        case .title2:
            return FontDescription(font: .bold, size: 22, style: .title2)
        case .title3:
            return FontDescription(font: .bold, size: 20, style: .title3)
        case .headline:
            return FontDescription(font: .bold, size: 16, style: .headline)
        case .headlineButton:
            return FontDescription(font: .semiBold, size: 16, style: .headline)
        case .body:
            return FontDescription(font: .regular, size: 16, style: .body)
        case .bodyWith(size: let size):
            return FontDescription(font: .regular, size: size, style: .body)
        case .callout:
            return FontDescription(font: .bold, size: 14, style: .callout)
        case .calloutButton:
            return FontDescription(font: .semiBold, size: 14, style: .callout)
        case .calloutButton2:
            return FontDescription(font: .semiBold, size: 13, style: .callout)
        case .subheadline:
            return FontDescription(font: .regular, size: 14, style: .subheadline)
        case .footnote:
            return FontDescription(font: .bold, size: 13, style: .footnote)
        case .caption1:
            return FontDescription(font: .regular, size: 13, style: .caption1)
        case .caption2:
            return FontDescription(font: .bold, size: 12, style: .caption2)
        }
    }
}

extension AppFonts {
    var font: UIFont {
        guard let font = UIFont(name: fontDescription.font.name, size: fontDescription.size) else {
            
            return UIFont.preferredFont(forTextStyle: fontDescription.style)
        }

        let fontMetrics = UIFontMetrics(forTextStyle: fontDescription.style)
        return fontMetrics.scaledFont(for: font)
    }
}

//MARK: - Convenience
extension Font {
    
    static let headline:Font = Font(AppFonts.headline.font)
    static let subheadline:Font = Font(AppFonts.subheadline.font)
    static let body:Font = Font(AppFonts.body.font)

}
