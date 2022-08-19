//
//  RealmMainView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/22/21.
//

import SwiftUI

struct AppMainView: View {
    
    @StateObject var viewModel: AppViewModel = .init()
    
    var body: some View {
        if viewModel.loggedIn {
            HomeView()
                .environmentObject(viewModel)
                .withErrorHandling()
        } else {
            VStack {
                Text("Welcome!")
                    .font(.headline)
                Text("Please log in via Discogs")
                    .font(.body)
                TryButton("Log In", action: viewModel.logIn)
                    .buttonStyle(.bordered)
                    .testIdentifier(LoginIdentifier.loginButton)
            }
        }
    }
    
}
