//
//  RealmMainView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/22/21.
//

import MGOAuth1
import SwiftUI

struct AppMainView: View {
    
    @StateObject private var viewModel: AppViewModel = .init()
    @StateObject private var oauthModel: OAuthObservable = .init(manager: DCManager.shared.oauthManager)
    
    var body: some View {
        if oauthModel.isLoggedIn {
            ReleaseListView()
                .environmentObject(viewModel)
                .withErrorHandling()
        } else {
            VStack {
                Text("Welcome!")
                    .font(.headline)
                Text("Please log in via Discogs")
                    .font(.body)
                Button("Log In") {
                    oauthModel.authorize()
                }.testIdentifier(LoginIdentifier.loginButton)
            }
            .sheet(isPresented: $oauthModel.authorizationSheetIsPresented) {
                WKView(url: $oauthModel.authorizationURL)
                    .environmentObject(oauthModel)
            }
        }
    }
}
