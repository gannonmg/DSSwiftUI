//
//  DCManager.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/30/21.
//

import Foundation
import MGKeychain
import MGOAuth1

class DCManager {
    
    let oauthManager: OAuthManager
    static let shared: DCManager = .init()
    
    private init() {
        self.oauthManager = .init(config: discogsOAuthConfig)
    }
    
    // MARK: OAuth
    func resetOauth() throws {
        try oauthManager.clearCredentials()
    }
    
    // MARK: Releases
    func getAllReleasesForUser(forceRefresh: Bool) async throws -> [DCReleaseModel] {
        let identityUrlString: String = "https://api.discogs.com/oauth/identity"
        let user: DCUser = try await oauthManager.get(from: identityUrlString)
        KeychainManager.shared.save(key: .discogsUsername, string: user.username)
        
        guard let username = KeychainManager.shared.get(for: .discogsUsername) else {
            throw AppError.messageError("No discogs username stored")
        }
        
        let initialPageUrl: String = "https://api.discogs.com/users/\(username)/collection/folders/0/releases?per_page=100"
        return try await getAllReleases(initialUrl: initialPageUrl)
    }
    
    private func getAllReleases(initialUrl: String) async throws -> [DCReleaseModel] {
        var releases: [DCReleaseModel] = []
        var urlString: String? = initialUrl
        while let pageUrlString: String = urlString {
            let response: CollectionReleasesResponse = try await oauthManager.get(from: pageUrlString)
            releases += response.releases
            urlString = response.pagination.urls.next
        }
        
        return releases
    }
    
    func getResource<T: Codable>(from resourceUrlString: String) async throws -> T {
        return try await oauthManager.get(from: resourceUrlString)
    }
}
