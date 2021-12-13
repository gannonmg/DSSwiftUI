//
//  LastFmLoginView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/11/21.
//

import SwiftUI

struct LFLoginView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = LFLoginViewModel()
    
    var body: some View {
        VStack {
            Text("Last.FM Login")
            TextField("Username", text: $viewModel.username, prompt: Text("Enter Username"))
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $viewModel.password, prompt: Text("Enter Password"))
            Button("Login") {
                viewModel.login {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
}
