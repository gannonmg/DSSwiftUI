//
//  DCManager.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/30/21.
//

import Foundation
import OAuthSwift

class DCManager {
    
    
    let oauthswift: OAuth1Swift!
    static let shared = DCManager()
    
    private init() {
        self.oauthswift = OAuth1Swift(consumerKey:     DCAuthInfo.key,
                                      consumerSecret:  DCAuthInfo.secret,
                                      requestTokenUrl: "https://api.discogs.com/oauth/request_token",
                                      authorizeUrl:    "https://www.discogs.com/oauth/authorize",
                                      accessTokenUrl:  "https://api.discogs.com/oauth/access_token")
        
        if let userToken = UserDefaults.standard.discogsUserToken,
           let userTokenSecret = UserDefaults.standard.discogsUserSecret
        {
            oauthswift.client.credential.oauthToken = userToken
            oauthswift.client.credential.oauthTokenSecret = userTokenSecret
        }
    }
    
    //MARK: Authentication
    func userLoginProcess(completion: @escaping  ((Error?)->Void)) {
        sendToWebLogin { error in
            guard error == nil else {
                completion(error)
                return
            }
            
            self.getUserIdentity(completion: completion)
        }
    }
    
    //Allows user to authenticate the app via oauth
    private func sendToWebLogin(completion: @escaping ((Error?)->Void)) {
        let _ = oauthswift.authorize(withCallbackURL: DCAuthInfo.callback) { result in
            switch result {
            case .success(let (credential, _ /*response*/, _/*parameters*/)):
                UserDefaults.standard.discogsUserToken = credential.oauthToken
                UserDefaults.standard.discogsUserSecret = credential.oauthTokenSecret
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    //Gets the user's username after oauth login
    func getUserIdentity(completion: @escaping ((Error?)->Void)) {
        oauthswift.client.get("https://api.discogs.com/oauth/identity") { result in
            switch result {
            case .success(let response):
                do {
                    let user = try JSONDecoder().decode(DCUser.self, from: response.data)
                    UserDefaults.standard.discogsUsername = user.username
                    completion(nil)
                } catch {
                    completion(error)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    //MARK: Releases
    func getAllReleasesForUser(forceRefresh: Bool = false, completion: @escaping ([ReleaseViewModel])->Void) {
        
        if forceRefresh == false,
           let releases = CoreDataManager.shared.fetchCollection(),
           releases.isEmpty == false
        {
            completion(releases)
            return
        }
        
        guard let username = UserDefaults.standard.discogsUsername else {
            completion([])
            return
        }
        
        let initialPageUrl = "https://api.discogs.com/users/\(username)/collection/folders/0/releases?per_page=100"
        getAllReleases(initialReleases: [], pageUrl: initialPageUrl) { releases in
            guard releases.isEmpty == false else {
                completion([])
                return
            }
            
            let releaseViewModels = releases.map { ReleaseViewModel(from: $0) }
            CoreDataManager.shared.saveCollection(of: releaseViewModels)
            completion(releaseViewModels)
        }
    }
    
    private func getAllReleases(initialReleases: [DCRelease], pageUrl: String, completion: @escaping ([DCRelease])->Void) {
        oauthswift.client.get(pageUrl) { result in
            switch result {
            case .success(let response):
                
                //Decode our data response to the release object
                do {
                    let response = try JSONDecoder().decode(CollectionReleasesResponse.self,
                                                            from: response.data)
                    
                    //Add our newly collected releases to what we've passed in
                    let releases = initialReleases + response.releases

                    //Check if we have a next url. If not, we're at the end and have everything we need, so bail
                    guard let nextPage = response.pagination.urls.next else {
                        completion(releases)
                        return
                    }
                    
                    //If we do have a next page url, let recursively call this function again, and get another chunk of albums
                    self.getAllReleases(initialReleases: releases,
                                        pageUrl: nextPage,
                                        completion: completion)
                } catch {
                    print("Error decoding albums: \(error.localizedDescription)")
                    completion(initialReleases)
                }
                
            case .failure(let error):
                print("Error with all albums: \(error.localizedDescription)")
                completion(initialReleases)
            }
        }
    }
    
    func getDetail(for resourceUrl: String, completion: @escaping (DCReleaseDetail?)->Void) {
        oauthswift.client.get(resourceUrl) { result in
            switch result {
            case .success(let response):
                do {
                    let detail = try JSONDecoder().decode(DCReleaseDetail.self,
                                                          from: response.data)
                    completion(detail)
                    print("Got album detail")
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
    
}


#warning("Switch to keychain")
extension UserDefaults {
    
    @objc var discogsUserToken: String? {
        get { string(forKey: "discogsUserToken") }
        set { setValue(newValue, forKey: "discogsUserToken") }
    }
    
    @objc var discogsUserSecret: String? {
        get { string(forKey: "discogsUserSecret") }
        set { setValue(newValue, forKey: "discogsUserSecret") }
    }
    
    @objc var discogsUsername: String? {
        get { string(forKey: "discogsUsername") }
        set { setValue(newValue, forKey: "discogsUsername") }
    }
    
}
