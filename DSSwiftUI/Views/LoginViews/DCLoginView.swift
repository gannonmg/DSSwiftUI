//
//  DCLoginView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/18/22.
//

import SwiftUI

struct DCLoginView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    
    @State private var showingWhy: Bool = false
    
    var body: some View {
        VStack {
            textStack
                .frame(maxHeight: .infinity)
            
            buttonStack
                .opacity(buttonOpacity)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .background(Color.vsPrimaryDark)
        .onAppear(perform: runAnimations)
    }
    
    var textStack: some View {
        VStack {
            Text("Welcome to...")
                .appFont(.lobster, size: 22)
                .foregroundColor(.white)
                .offset(x: 0, y: welcomeOffset)
                .opacity(welcomeOpacity)
                .vsShadow(verticalSpread: 2)
            Text("Vinyl Space")
                .appFont(.lobster, size: 60)
                .foregroundColor(.white)
                .zIndex(1)
                .vsShadow(verticalSpread: 3)
                .mask(Rectangle().frame(maxHeight: titleHeight))
        }
    }
    
    var buttonStack: some View {
        VStack(spacing: 12) {
            VSButton(
                "Log In With Discogs",
                buttonStyle: .light,
                action: viewModel.logIn
            )
            VSUnderlineButton("Why?") {

            }
        }
    }
    
    // MARK: Animation
    private let welcomeDuration: Double = 0.75
    @State private var welcomeOffset: CGFloat = 50
    @State private var welcomeOpacity: CGFloat = 0
    
    private let titleDuration: Double = 1
    private var titleDelay: Double { welcomeDuration }
    @State private var titleHeight: CGFloat = 0
    
    private let buttonDuration: Double = 0.75
    private var buttonDelay: Double { welcomeDuration + (titleDuration / 2) }
    @State private var buttonOpacity: CGFloat = 0
    
    func runAnimations() {
        withAnimation(
            .spring(
                response: 0.8,
                dampingFraction: 0.5,
                blendDuration: welcomeDuration
            )
        ) {
            welcomeOffset = 0
        }
        
        withAnimation(.easeIn(duration: welcomeDuration)) {
            welcomeOpacity = 1
        }
        
        withAnimation(
            .easeInOut(duration: titleDuration)
            .delay(titleDelay)
        ) {
            titleHeight = .infinity
        }
        
        withAnimation(
            .easeInOut(duration: buttonDuration)
            .delay(buttonDelay)
        ) {
            buttonOpacity = 1
        }
    }
}

struct DiscogsExplanationView: View {
    
    let titleText: String = "Why do I need to log in with Discogs?"
    let bodyText: String =
            """
            Vinyl Space uses information provided by  you and other Discogs users \
            to display your collection and allow for easy filtering using the provide \
            genres, styles, and formats. If you don’t have a Discogs account, \
            you’ll need to create one at www.discogs.com and begin catloguing your collection.
            """
    
    var body: some View {
        VStack {
            Text(titleText)
                .appFont(.robotoBold, size: 20)
                .foregroundColor(.vsDarkText)

            Text(bodyText)
                .appFont(.robotoRegular, size: 16)
                .foregroundColor(.vsDarkText)
        }
    }
}

struct DCLoginView_Previews: PreviewProvider {
    static var previews: some View {
        DCLoginView()
    }
}
