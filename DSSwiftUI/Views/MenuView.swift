//
//  MenuView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/31/21.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationView {
            List {
                discogsItem
                lastFmItem
            }
            .navigationTitle("Menu")
        }
    }
    
    var discogsItem: some View {
        HStack {
            Text("Discogs")
            Spacer()
            Button("Login") {
                print("Tapped Discogs")
            }
        }
    }
    
    var lastFmItem: some View {
        HStack {
            Text("Last Fm")
            Spacer()
            Button("Login") {
                print("Tapped LastFm")
            }
        }
    }
    
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
