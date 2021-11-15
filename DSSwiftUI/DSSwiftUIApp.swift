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

    init() {
        setGlobalAppearances()
    }
    
    var body: some Scene {
        WindowGroup {
//            RealmListView()
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

func setGlobalAppearances() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(.textPrimary)]
    appearance.titleTextAttributes = [.foregroundColor: UIColor(.textPrimary)]
    appearance.backgroundColor = UIColor(.navBar)
    UINavigationBar.appearance().barTintColor = UIColor(.navBar)
    
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    
    UITabBar.appearance().barTintColor = UIColor(.navBar)
}
