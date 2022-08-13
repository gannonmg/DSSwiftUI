//
//  DCManager.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/30/21.
//

import Foundation
import MGKeychain
import OAuthSwift

class DCManager {
    
    private var oauthSwift: OAuth1Swift!
    static let shared: DCManager = .init()
    
    private init() {
        self.oauthSwift = OAuth1Swift(consumerKey: DCAuthInfo.key,
                                      consumerSecret: DCAuthInfo.secret,
                                      requestTokenUrl: "https://api.discogs.com/oauth/request_token",
                                      authorizeUrl: "https://www.discogs.com/oauth/authorize",
                                      accessTokenUrl: "https://api.discogs.com/oauth/access_token")
        
        if let userToken: String = KeychainManager.shared.get(for: .discogsUserToken),
           let userTokenSecret: String = KeychainManager.shared.get(for: .discogsUserSecret) {
            oauthSwift.client.credential.oauthToken = userToken
            oauthSwift.client.credential.oauthTokenSecret = userTokenSecret
        }
    }
    
    // MARK: Authentication
    func userLoginProcess() async throws {
        try await sendToWebLogin()
        try await self.getUserIdentity()
    }
    
    // Allows user to authenticate the app via oauth
    private func sendToWebLogin() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            _ = oauthSwift.authorize(withCallbackURL: DCAuthInfo.callback) { result in
                switch result {
                case .success(let (credential, _ /*response*/, _/*parameters*/)):
                    KeychainManager.shared.save(key: .discogsUserToken, string: credential.oauthToken)
                    KeychainManager.shared.save(key: .discogsUserSecret, string: credential.oauthTokenSecret)
                    continuation.resume(returning: ())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // Gets the user's username after oauth login
    private func getUserIdentity() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            oauthSwift.client.get("https://api.discogs.com/oauth/identity") { result in
                switch result {
                case .success(let response):
                    do {
                        let user: DCUser = try JSONDecoder().decode(DCUser.self, from: response.data)
                        KeychainManager.shared.save(key: .discogsUsername, string: user.username)
                        continuation.resume(returning: ())
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func resetOauth() {
        self.oauthSwift = OAuth1Swift(consumerKey: DCAuthInfo.key,
                                      consumerSecret: DCAuthInfo.secret,
                                      requestTokenUrl: "https://api.discogs.com/oauth/request_token",
                                      authorizeUrl: "https://www.discogs.com/oauth/authorize",
                                      accessTokenUrl: "https://api.discogs.com/oauth/access_token")
    }
    
    // MARK: Releases
    func getAllReleasesForUser(forceRefresh: Bool) async throws -> [DCReleaseModel] {
        guard let username = KeychainManager.shared.get(for: .discogsUsername) else {
            throw AppError.messageError("No discogs username stored")
        }
        
        let initialPageUrl: String = "https://api.discogs.com/users/\(username)/collection/folders/0/releases?per_page=100"
        return try await getAllReleases(initialUrl: initialPageUrl)
    }
    
    private func getAllReleases(initialUrl: String) async throws -> [DCReleaseModel] {
        var releases: [DCReleaseModel] = []
        var url: URL? = .init(string: initialUrl)
        while let pageUrl: URL = url {
            let response: CollectionReleasesResponse = try await getReleases(from: pageUrl)
            releases += response.releases
            url = URL(optionalString: response.pagination.urls.next)
        }
        
        return releases
    }
    
    private func getReleases(from pageUrl: URL) async throws -> CollectionReleasesResponse {
        return try await withCheckedThrowingContinuation { continuation in
            oauthSwift.client.get(pageUrl) { result in
                switch result {
                case .success(let response):
                    do {
                        let response: CollectionReleasesResponse = try JSONDecoder().decode(
                            CollectionReleasesResponse.self,
                            from: response.data
                        )
                        
                        continuation.resume(returning: response)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
        
    func getDetail(for resourceUrl: String) async throws -> DCReleaseDetailModel? {
        return try await withCheckedThrowingContinuation { continuation in
            oauthSwift.client.get(resourceUrl) { result in
                switch result {
                case .success(let response):
                    do {
                        let detail: DCReleaseDetailModel = try JSONDecoder().decode(
                            DCReleaseDetailModel.self,
                            from: response.data
                        )
                        
                        continuation.resume(returning: detail)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
}
