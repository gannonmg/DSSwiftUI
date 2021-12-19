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
    
    func login(completion: @escaping (() -> Void)) {
        Task {
            let session = await RemoteClientManager.getLastFmUserSession(username: username, password: password)
            if let session = session {
                KeychainManager.shared.save(key: .lastFmSessionKey, string: session.key)
                completion()
            }
        }
    }

}
