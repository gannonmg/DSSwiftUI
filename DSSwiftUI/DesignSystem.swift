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
    static let vsDarkText: Color = Color("DarkText")
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

// swiftlint:disable statement_position
struct VSButton: View {
    @EnvironmentObject var errorHandling: ErrorHandling

    enum VSButtonStyle {
        case light, dark
        
        var fontColor: Color { (self == .light) ? .vsDarkText : .white }
        var backgroundColor: Color { (self == .light) ? .white : .vsPrimaryDark }
    }
    
    let title: String
    let buttonStyle: VSButtonStyle
    let action: ThrowingAction
    
    init(_ title: String, buttonStyle: VSButtonStyle, action: @escaping ThrowingAction) {
        self.title = title
        self.buttonStyle = buttonStyle
        self.action = action
    }
    
    var body: some View {
        Button {
            do { try action() }
            catch { errorHandling.handle(error: error) }
        } label: {
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
    @EnvironmentObject var errorHandling: ErrorHandling

    let title: String
    let image: Image?
    let action: ThrowingAction
    
    init(_ title: String, image: Image? = nil, action: @escaping ThrowingAction) {
        self.title = title
        self.image = image
        self.action = action
    }

    var body: some View {
        Button {
            do { try action() }
            catch { errorHandling.handle(error: error) }
        } label: {
            if let image: Image = image {
                HStack {
                    Text(title)
                    image
                        .resizable()
                        .frame(width: 12, height: 12)
                        .fixedSize()
                }
                .fixedSize()
            } else {
                Text(title)
            }
        }
        .modifier(SecondaryButtonModifier())
    }
}

struct SecondaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .appFont(.robotoMedium, size: 14)
            .foregroundColor(.vsDarkText)
            .padding(.horizontal, 8)
            .frame(minWidth: 72, idealWidth: 72, minHeight: 28, idealHeight: 28)
            .background {
                RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.white)
                .vsShadow()
            }
    }
}

struct VSUnderlineButton: View {
    @EnvironmentObject var errorHandling: ErrorHandling

    let title: String
    let action: ThrowingAction
    
    init(_ title: String, action: @escaping ThrowingAction) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button {
            do { try action() }
            catch { errorHandling.handle(error: error) }
        } label: {
            Text("Why?")
                .appFont(.robotoRegular, size: 16)
                .foregroundColor(.white)
                .underline()
        }
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
