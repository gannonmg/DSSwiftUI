//
//  Design+Buttons.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/20/22.
//

import SwiftUI

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
/*
enum VSButtonStyle {
    case large(theme: VSButtonTheme)
    case small
    case underline
    
    enum VSButtonTheme {
        case light, dark
        
        var fontColor: Color { (self == .light) ? .vsDarkText : .white }
        var backgroundColor: Color { (self == .light) ? .white : .vsPrimaryDark }
    }
    
}

struct LargeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
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

struct TryButton<Label>: View where Label: View {
    var action: () throws -> Void
    @ViewBuilder var label: () -> Label
    @EnvironmentObject var errorHandling: ErrorHandling
    
    var body: some View {
        Button(action: {
                do {
                    try action()
                } catch {
                    self.errorHandling.handle(error: error)
                }
            },
            label: label)
    }
}

extension TryButton where Label == Text {
    init(_ title: String, buttonStyle: VSButtonStyle, action: @escaping ThrowingAction) {
        self.init(action: action) {
            Text(title)
        }
    }
}

extension TryButton where Label == Text {
    init(_ titleKey: LocalizedStringKey, action: @escaping () throws -> Void) {
        self.init(action: action, label: { Text(titleKey) })
    }

    init<S>(_ title: S, action: @escaping () throws -> Void) where S: StringProtocol {
        self.init(action: action, label: { Text(title) })
    }
}

extension Button where Label == Text {
    init<S: StringProtocol>(_ title: S, style: VSButtonStyle, action: @escaping StandardAction) {
        self.init {
            action()
        } label: {
            Text(title)
        }
    }
    
    init<S: StringProtocol>(_ title: S, style: VSButtonStyle, action: @escaping ThrowingAction) {
        self.init {
            action()
        } label: {
            Text(title)
        }
    }
}
 */
