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

    var body: some Scene {
        WindowGroup {
            AppMainView()
                .onOpenURL { url in
                    if url.host == "oauth-callback" {
                        OAuthSwift.handle(url: url)
                    }
                }
        }
    }
}
