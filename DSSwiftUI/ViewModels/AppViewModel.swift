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
                                               selector: #selector(checkForToken),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    func logIn() {
        RemoteClientManager.userLoginProcess { error in
            if let error = error {
                print("Login error \(error)")
            } else {
                print("Logged user in")
                RemoteClientManager.getAllReleasesForUser(forceRefresh: false) { releases in
                    RealmManager.shared.update(with: releases)
                    print("Got and stored releases")
                }
            }
        }
    }
    
    func logOutAll() {
        KeychainManager.shared.remove(key: .discogsUsername)
        KeychainManager.shared.remove(key: .discogsUserToken)
        KeychainManager.shared.remove(key: .discogsUserSecret)
        KeychainManager.shared.remove(key: .lastFmSessionKey)

        discogsToken = nil
        lastFmKey = nil
        
        RealmManager.shared.deleteAllReleases()
        RemoteClientManager.resetOauth()
    }
    
    func checkLastFmKey() {
        self.lastFmKey = KeychainManager.shared.get(for: .lastFmSessionKey)
    }
    
    func logOutLastFm() {
        KeychainManager.shared.remove(key: .lastFmSessionKey)
        lastFmKey = nil
    }
    
    @objc func checkForToken() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.discogsToken = KeychainManager.shared.get(for: .discogsUserToken)
        }
    }
    
}
