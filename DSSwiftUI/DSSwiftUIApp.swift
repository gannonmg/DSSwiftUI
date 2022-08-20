//
//  DSSwiftUIApp.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/30/21.
//

import OAuthSwift
import SwiftUI

@main
struct DSSwiftUIApp: App {
    @StateObject var viewModel: AppViewModel = .init()

    var body: some Scene {
        WindowGroup {
            currentView
                .withErrorHandling()
                .environmentObject(viewModel)
                .onAppear(perform: AppEnvironment.shared.resetTestApp)
                .onOpenURL { url in
                    if url.host == "oauth-callback" {
                        OAuthSwift.handle(url: url)
                    }
                }
        }
    }
    
    var currentView: some View {
        if viewModel.loggedIn {
            return AnyView(HomeView())
        } else {
            return AnyView(DCLoginView())
        }
    }
}
