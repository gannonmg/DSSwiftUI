//
//  RealmMainView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 11/22/21.
//

import SwiftUI

class AppViewModel: ObservableObject {
    
    static let shared = AppViewModel()
    
    @Published var token: String?
    var loggedIn: Bool { token != nil }
    
    private init() {
        token = KeychainManager.shared.get(for: .discogsUserToken)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkForToken),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    func logIn() {
        DCManager.shared.userLoginProcess { error in
            if let error = error {
                print("Login error \(error)")
            } else {
                print("Logged user in")
                DCManager.shared.getAllReleasesForUser { releases in
                    RealmManager.shared.update(with: releases)
                    print("Got and stored releases")
                }
            }
        }
    }
    
    func logOut() {
        KeychainManager.shared.remove(key: .discogsUsername)
        KeychainManager.shared.remove(key: .discogsUserToken)
        KeychainManager.shared.remove(key: .discogsUserSecret)
        
        token = nil
        
        RealmManager.shared.deleteAllReleases()
        DCManager.shared.resetOauth()
    }
    
    @objc func checkForToken() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.token = KeychainManager.shared.get(for: .discogsUserToken)
        }
    }
    
}

struct AppMainView: View {
    
    @ObservedObject var viewModel: AppViewModel = .shared
    
    var body: some View {
        if viewModel.loggedIn {
            RealmListView()
        } else {
            VStack {
                Text("Welcome!")
                    .font(.headline)
                Text("Please log in via Discogs")
                    .font(.body)
                Button("Log In", action: viewModel.logIn)
                    .buttonStyle(.bordered)
            }
        }
    }
    
}

struct RealmMainView_Previews: PreviewProvider {
    static var previews: some View {
        AppMainView()
    }
}
