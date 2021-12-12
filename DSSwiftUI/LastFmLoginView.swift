//
//  LastFmLoginView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/11/21.
//

import SwiftUI

struct LastFmLoginView: View {
    
    @State private(set) var username: String = ""
    @State private(set) var password: String = ""
    
    var body: some View {
        VStack {
            Text("Last.FM Login")
            TextField("Username", text: $username, prompt: Text("Enter Username"))
            TextField("Password", text: $password, prompt: Text("Enter Password"))
            Button("Login") {
                
            }
        }
    }
    
    func login() {
        LFManager.shared.getUserSession(username: username, password: password) { session in
            if let session = session {
                KeychainManager.shared.save(key: .lastFmSessionKey, string: session.key)
            }
        }
    }
}

struct LastFmLoginView_Previews: PreviewProvider {
    static var previews: some View {
        LastFmLoginView()
    }
}
