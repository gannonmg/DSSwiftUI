//
//  AppViewModel.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/13/21.
//

import MGKeychain
import SwiftUI

class AppViewModel: ObservableObject {
    
    @Published private(set) var discogsToken: String?
    @Published private(set) var lastFmKey: String?
    @Published var showingLastFmLogin: Bool = false

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

    func logIn() throws {
        Task {
            try await RemoteClientManager.shared.userLoginProcess()
            let releases: [DCReleaseModel] = try await RemoteClientManager.shared.getAllReleasesForUser(forceRefresh: false)
            RealmManager.shared.update(with: releases)
        }
    }
    
    func logOutAll() {
        KeychainManager.shared.remove(key: .discogsUsername)
        KeychainManager.shared.remove(key: .discogsUserToken)
        KeychainManager.shared.remove(key: .discogsUserSecret)
        KeychainManager.shared.remove(key: .lastFmSessionKey)
        
        RealmManager.shared.deleteAllReleases()
        RemoteClientManager.shared.resetOauth()
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
