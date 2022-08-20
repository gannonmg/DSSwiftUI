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
        VStack(spacing: 16) {
            headerView
            fieldStack
                .padding(.horizontal, 20)
            loginButton
            Spacer()
        }
        .background {
            Color.vsBackground
                .ignoresSafeArea()
        }
    }
    
    var headerView: some View {
        HStack {
            Text("Last.fm Login")
                .appFont(.robotoBold, size: 24)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, minHeight: 75, idealHeight: 75)
        .background {
            Color.vsPrimaryDark
                .vsShadow()
        }
        .overlay(alignment: .trailing) {
            Button {
                dismiss()
            } label: {
                let buttonSize: CGFloat = 16
                Image.closeIcon
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: buttonSize, height: buttonSize)
                    .foregroundColor(.white)
            }
            .padding(.trailing, 20)
        }
    }
    
    var fieldStack: some View {
        VStack(spacing: 16) {
            VSTextField(
                labelText: "Username:",
                prompText: "Last.fm Username",
                text: $viewModel.username,
                contentType: .username,
                textIdentifier: .usernameField,
                disableAutocorrect: true,
                autocapitalization: .never
            )
            
            VSTextField(
                labelText: "Password:",
                prompText: "Last.fm Password",
                text: $viewModel.password,
                contentType: .password,
                textIdentifier: .passwordField
            )
        }
    }
    
    var loginButton: some View {
        VSSecondaryButton("Login") {
            try viewModel.login {
                dismiss.callAsFunction()
            }
        }
        .testIdentifier(LastFmIdentifier.loginButton)
    }
    
    struct VSTextField: View {
        @State private var hidePassword: Bool = true
        
        let protectedFields: [UITextContentType] = [.password, .newPassword]
        var isSecure: Bool { protectedFields.contains(contentType) }

        let labelText: String
        let prompText: String
        @Binding var text: String
        let contentType: UITextContentType
        let testIdentifier: LastFmIdentifier
        let disableAutocorrect: Bool
        let autocapitalization: TextInputAutocapitalization
        
        init(
            labelText: String,
            prompText: String,
            text: Binding<String>,
            contentType: UITextContentType,
            textIdentifier: LastFmIdentifier,
            disableAutocorrect: Bool = false,
            autocapitalization: TextInputAutocapitalization = .sentences
        ) {
            self.labelText = labelText
            self.prompText = prompText
            self._text = text
            self.contentType = contentType
            self.testIdentifier = textIdentifier
            self.disableAutocorrect = disableAutocorrect
            self.autocapitalization = autocapitalization
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(labelText)
                    .appFont(.robotoBold, size: 16)
                    .foregroundColor(.white)
                VStack(spacing: 4) {
                    HStack {
                        textField
                            .testIdentifier(testIdentifier)
                            .textContentType(contentType)
                            .disableAutocorrection(disableAutocorrect)
                            .textInputAutocapitalization(autocapitalization)
                            .placeholder(when: text.isEmpty) {
                                Text(prompText)
                                    .appFont(.robotoRegular, size: 16)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                        
                        if !text.isEmpty {
                            clearButton
                        }
                        
                        if isSecure {
                            securityToggle
                        }
                    }
                    Rectangle()
                        .foregroundColor(.white)
                        .height(1)
                }
            }
        }
        
        var textField: some View {
            if isSecure && hidePassword {
                return AnyView(SecureField("", text: $text))
            } else {
                return AnyView(TextField("", text: $text))
            }
        }
        
        var clearButton: some View {
            Button {
                text = ""
            } label: {
                Image.closeIcon
                    .foregroundColor(.white)
            }
        }
        
        var securityToggle: some View {
            Button {
                withAnimation {
                    hidePassword.toggle()
                }
            } label: {
                let name: String = hidePassword ? "eye.slash" : "eye"
                Image(systemName: name)
                    .foregroundColor(.white)
                    .transition(.opacity)
            }
        }
    }
}

struct LFLoginView_Previews: PreviewProvider {
    
    @State static var text: String = ""

    static var previews: some View {
        VStack {
            LFLoginView.VSTextField(
                labelText: "Username:",
                prompText: "Last.fm Username",
                text: $text,
                contentType: .username,
                textIdentifier: .usernameField
            )
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.vsBackground.ignoresSafeArea()
        }
    }
}
