//
//  LastFmLoginView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/11/21.
//

import SwiftUI

struct LFLoginView: View {
    
    @Environment(\.dismiss) var dismiss: DismissAction
    @StateObject private var viewModel: LFLoginViewModel = .init()
    
    var body: some View {
        VStack {
            Text("Last.FM Login")
            TextField("Username", text: $viewModel.username, prompt: Text("Enter Username"))
                .testIdentifier(LastFmIdentifier.usernameField)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $viewModel.password, prompt: Text("Enter Password"))
                .testIdentifier(LastFmIdentifier.passwordField)
            TryButton("Login") {
                try viewModel.login {
                    self.dismiss()
                }
            }
            .testIdentifier(LastFmIdentifier.loginButton)
        }
    }
    
}
