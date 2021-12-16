//
//  DCManager.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/30/21.
//

import Foundation
import OAuthSwift

class DCManager {
    
    private var oauthSwift: OAuth1Swift!
    static let shared = DCManager()
    
    private init() {
        self.oauthSwift = OAuth1Swift(consumerKey: DCAuthInfo.key,
                                      consumerSecret: DCAuthInfo.secret,
                                      requestTokenUrl: "https://api.discogs.com/oauth/request_token",
                                      authorizeUrl: "https://www.discogs.com/oauth/authorize",
                                      accessTokenUrl: "https://api.discogs.com/oauth/access_token")
        
        if let userToken = KeychainManager.shared.get(for: .discogsUserToken),
           let userTokenSecret = KeychainManager.shared.get(for: .discogsUserSecret) {
            oauthSwift.client.credential.oauthToken = userToken
            oauthSwift.client.credential.oauthTokenSecret = userTokenSecret
        }
    }
    
    // MARK: Authentication
    func userLoginProcess(completion: @escaping  ((Error?) -> Void)) {
        sendToWebLogin { error in
            guard error == nil else {
                completion(error)
                return
            }
            
            self.getUserIdentity(completion: completion)
        }
    }
    
    // Allows user to authenticate the app via oauth
    private func sendToWebLogin(completion: @escaping ((Error?) -> Void)) {
        _ = oauthSwift.authorize(withCallbackURL: DCAuthInfo.callback) { result in
            switch result {
            case .success(let (credential, _ /*response*/, _/*parameters*/)):
                KeychainManager.shared.save(key: .discogsUserToken, string: credential.oauthToken)
                KeychainManager.shared.save(key: .discogsUserSecret, string: credential.oauthTokenSecret)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    // Gets the user's username after oauth login
    func getUserIdentity(completion: @escaping ((Error?) -> Void)) {
        oauthSwift.client.get("https://api.discogs.com/oauth/identity") { result in
            switch result {
            case .success(let response):
                do {
                    let user = try JSONDecoder().decode(DCUser.self, from: response.data)
                    KeychainManager.shared.save(key: .discogsUsername, string: user.username)
                    completion(nil)
                } catch {
                    completion(error)
                }
            case .failure(let error):
                completion(error)
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
    func getAllReleasesForUser(forceRefresh: Bool = false, completion: @escaping ([DCReleaseModel]) -> Void) {
        
        guard let username = KeychainManager.shared.get(for: .discogsUsername) else {
            completion([])
            return
        }
        
        let initialPageUrl = "https://api.discogs.com/users/\(username)/collection/folders/0/releases?per_page=100"
        getAllReleases(initialReleases: [], pageUrl: initialPageUrl) { releases in
            guard releases.isEmpty == false else {
                #warning("Handle eempty release response")
                completion([])
                return
            }
            
            completion(releases)
        }
    }
    
    private func getAllReleases(initialReleases: [DCReleaseModel], pageUrl: String, completion: @escaping ([DCReleaseModel]) -> Void) {
        oauthSwift.client.get(pageUrl) { result in
            switch result {
            case .success(let response):
                
                // Decode our data response to the release object
                do {
                    
                    // print(String(decoding: response.data, as: UTF8.self))
                    let response = try JSONDecoder().decode(CollectionReleasesResponse.self,
                                                            from: response.data)
                    
                    // Add our newly collected releases to what we've passed in
                    let releases = initialReleases + response.releases

                    // Check if we have a next url. If not, we're at the end and have everything we need, so bail
                    guard let nextPage = response.pagination.urls.next else {
                        completion(releases)
                        return
                    }
                    
                    // If we do have a next page url, let recursively call this function again, and get another chunk of albums
                    self.getAllReleases(initialReleases: releases,
                                        pageUrl: nextPage,
                                        completion: completion)
                } catch {
                    print("Error decoding albums: \(error)")
                    completion(initialReleases)
                }
                
            case .failure(let error):
                print("Error with all albums: \(error.localizedDescription)")
                completion(initialReleases)
            }
        }
    }
    
    func getDetail(for resourceUrl: String, completion: @escaping (DCReleaseDetailModel?) -> Void) {
        oauthSwift.client.get(resourceUrl) { result in
            switch result {
            case .success(let response):
                do {
                    let detail = try JSONDecoder().decode(DCReleaseDetailModel.self,
                                                          from: response.data)
                    print("Got album detail")
                    completion(detail)
                } catch {
                    print("Error getting album detail: \(error). Resourse \(resourceUrl)")
                    completion(nil)
                }
            case .failure(let error):
                print("Error getting album detail: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func getDetail(for resourceUrl: String) async -> DCReleaseDetailModel? {
        return await withCheckedContinuation { continuation in
            oauthSwift.client.get(resourceUrl) { result in
                switch result {
                case .success(let response):
                    do {
                        let detail = try JSONDecoder().decode(DCReleaseDetailModel.self,
                                                              from: response.data)
                        print("Got album detail")
                        continuation.resume(returning: detail)
                    } catch {
                        print("Error getting album detail: \(error). Resourse \(resourceUrl)")
                        continuation.resume(returning: nil)
                    }
                case .failure(let error):
                    print("Error getting album detail: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
}
