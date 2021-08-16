//
//  MainView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/31/21.
//

import SwiftUI

struct MainView: View {

    @State private var tabSelection = 1

    var body: some View {
        TabView(selection: $tabSelection) {
            LoginView()
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("Collection")
                }
                .tag(1)
            ReleaseListView()
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("Release List")
                }
                .tag(2)
            MenuView()
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("Menu")
                }
                .tag(3)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
