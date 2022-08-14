//
//  DSSwiftUIApp.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/30/21.
//

import SwiftUI

@main
struct DSSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            AppMainView()
                .onAppear(perform: AppEnvironment.shared.resetTestApp)
        }
    }
}
