//
//  AppViewModel.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/13/21.
//

import SwiftUI

class AppViewModel: ObservableObject {
    
    @Published private(set) var discogsToken: String?
    @Published private(set) var lastFmKey: String?
    var loggedIn: Bool { discogsToken != nil }
    var loggedInToLastFm: Bool { lastFmKey != nil }
    
    init() {
        discogsToken = KeychainManager.shared.get(for: .discogsUserToken)
        lastFmKey = KeychainManager.shared.get(for: .lastFmSessionKey)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keychainUpdated),
                                               name: .keychainUpdated,
                                               object: nil)
    }

    func logIn() {
        Task {
            try! await RemoteClientManager.userLoginProcess()
            let releases = try! await RemoteClientManager.getAllReleasesForUser(forceRefresh: false)
            RealmManager.shared.update(with: releases)
        }
    }
    
    func logOutAll() {
        KeychainManager.shared.remove(key: .discogsUsername)
        KeychainManager.shared.remove(key: .discogsUserToken)
        KeychainManager.shared.remove(key: .discogsUserSecret)
        KeychainManager.shared.remove(key: .lastFmSessionKey)
        
        RealmManager.shared.deleteAllReleases()
        RemoteClientManager.resetOauth()
    }
    
    func logOutLastFm() {
        KeychainManager.shared.remove(key: .lastFmSessionKey)
    }
    
    @objc func keychainUpdated() {
        DispatchQueue.main.async {
            self.discogsToken = KeychainManager.shared.get(for: .discogsUserToken)
            self.lastFmKey = KeychainManager.shared.get(for: .lastFmSessionKey)
        }
    }
    
}
