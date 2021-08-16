//
//  ViewExtensions.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/31/21.
//

import SwiftUI

typealias StandardAction = (()->Void)

//MARK: - Common
extension View {
    
    func height(_ height: CGFloat) -> some View {
        self.frame(height: height)
    }
    
    func width(_ width: CGFloat) -> some View {
        self.frame(width: width)
    }
    
    func standardShadow() -> some View {
        self.shadow(color: .black.opacity(0.3),
                    radius: 3,
                    x: 0, y: 2)
    }
    
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
    
}

//MARK: - Progress Indicators
struct FullScreenProgressView: View {
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
    }
}

//MARK: - Login Field
struct LoginFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
    }
}

extension TextField {
    func loginFieldStyle() -> TextField {
        self.modifier(LoginFieldModifier()).content
    }
}

//MARK: - Login Button
struct LoginButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .height(48)
            .background(Color.green)
            .cornerRadius(8)
            .padding(.horizontal, 16)
    }
}

extension Button {
    func loginButtonStyle() -> Button {
        self.modifier(LoginButtonModifier()).content
    }
}
