//
//  LastFmLoginView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/11/21.
//

import SwiftUI

struct LastFmLoginView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private(set) var username: String = ""
    @State private(set) var password: String = ""
    
    var body: some View {
        VStack {
            Text("Last.FM Login")
            TextField("Username", text: $username, prompt: Text("Enter Username"))
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password, prompt: Text("Enter Password"))
            Button("Login") {
                login()
            }
        }
    }
    
    func login() {
        LFManager.shared.getUserSession(username: username, password: password) { session in
            if let session = session {
                print("Logged in successfully")
                KeychainManager.shared.save(key: .lastFmSessionKey, string: session.key)
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct LastFmLoginView_Previews: PreviewProvider {
    static var previews: some View {
        LastFmLoginView()
    }
}
