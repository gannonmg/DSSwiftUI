//
//  LoginView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/30/21.
//

import SwiftUI

let lightGreyColor = Color(.sRGB, white: 239/255, opacity: 1)

class LoginViewModel: ObservableObject {
    
    @Published var token:String? = UserDefaults.standard.discogsUserToken
    @Published var thing:Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkForToken),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

    }
    
    func requestToken() {
        DCManager.shared.userLoginProcess { error in
            if let error = error {
                print("Login error \(error)")
            } else {
                print("Logged user in")
            }
        }
    }
    
    func getIdentity() {
        DCManager.shared.getUserIdentity { error in
            if let error = error {
                print("Identity error \(error)")
            } else {
                print("Got user identity")
            }
        }
    }
    
    @objc func checkForToken() {
        self.token = UserDefaults.standard.discogsUserToken
    }
    
}

struct LoginView: View {
    
    @StateObject var viewModel:LoginViewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                
                if let token = viewModel.token {
                    Text(token)
                } else {
                    Text("No token")
                }
                
                Button("Get Token") {
                    viewModel.requestToken()
                }
                .loginButtonStyle()

                Button("Get identity") {
                    viewModel.getIdentity()
                }
                .loginButtonStyle()
                
                Button("Empty Empties") {
                    CoreDataManager.shared.deleteCollections(emptyOnly: true)
                }
                
                Button("Delete all CoreData") {
                    CoreDataManager.shared.deleteCollections(emptyOnly: false)
                }

                Spacer()
            }
            .padding(24)
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
