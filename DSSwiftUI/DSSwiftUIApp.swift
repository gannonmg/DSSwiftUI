//
//  DSSwiftUIApp.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/30/21.
//

import SwiftUI
import OAuthSwift

@main
struct DSSwiftUIApp: App {

    var body: some Scene {
        WindowGroup {
            MainView()
//                .environment(\.managedObjectContext,
//                             CoreDataManager.shared.container.viewContext)
                .onOpenURL { url in
                    if url.host == "oauth-callback" {
                        OAuthSwift.handle(url: url)
                    }
                }
        }
    }
}
