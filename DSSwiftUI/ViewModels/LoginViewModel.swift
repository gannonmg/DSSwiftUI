//
//  LoginViewModel.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 9/8/21.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    
    @Published var token:String? = KeychainManager.shared.get(for: .discogsUserToken)
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
    
    func killUserInfo() {
        KeychainManager.shared.remove(key: .discogsUsername)
        KeychainManager.shared.remove(key: .discogsUserToken)
        KeychainManager.shared.remove(key: .discogsUserSecret)
    }
    
    @objc func checkForToken() {
        self.token = KeychainManager.shared.get(for: .discogsUserToken)
    }
    
}
