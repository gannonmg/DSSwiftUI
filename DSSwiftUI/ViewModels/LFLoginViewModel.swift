//
//  LFLoginViewModel.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/13/21.
//

import Foundation

class LFLoginViewModel: ObservableObject {
    
    @Published var username: String = ""
    @Published var password: String = ""
    
    func login(completion: @escaping (()->Void)) {
        LFManager.shared.getUserSession(username: username, password: password) { session in
            if let session = session {
                print("Logged in successfully")
                KeychainManager.shared.save(key: .lastFmSessionKey, string: session.key)
                completion()
            }
        }
    }

}
