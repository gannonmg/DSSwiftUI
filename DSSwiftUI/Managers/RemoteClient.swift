//
//  RemoteClient.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/16/21.
//

import Foundation

protocol RemoteClientProtocol: DiscogsProxy, LastFmProxy {}

protocol LastFmProxy {
    func getLastFmUserSession(username: String, password: String, completion: @escaping((LFSession?) -> Void))
    func scrobbleRelease(_ release: ReleaseViewModel)
}

protocol DiscogsProxy {
    func getAllReleasesForUser(forceRefresh: Bool, completion: @escaping ([DCReleaseModel]) -> Void)
    func getDetail(for release: ReleaseViewModel) async -> DCReleaseDetailModel?
    func resetOauth()
}

final class RemoteClientManager: RemoteClientProtocol {
    
    let shared: RemoteClientManager = .init()
    private init() {}

    // MARK: Discogs proxy
    func getAllReleasesForUser(forceRefresh: Bool, completion: @escaping ([DCReleaseModel]) -> Void) {
        DCManager.shared.getAllReleasesForUser(forceRefresh: forceRefresh, completion: completion)
    }
    
    func getDetail(for release: ReleaseViewModel) async -> DCReleaseDetailModel? {
        return await DCManager.shared.getDetail(for: release.resourceURL)
    }
    
    func resetOauth() {
        DCManager.shared.resetOauth()
    }
    
    // MARK: last.fm proxy
    func getLastFmUserSession(username: String, password: String, completion: @escaping ((LFSession?) -> Void)) {
        LFManager.shared.getUserSession(username: username, password: password, completion: completion)
    }
    
    func scrobbleRelease(_ release: ReleaseViewModel) {
        LFManager.shared.scrobbleRelease(release)
    }
    
}

final class MockRemoteClientManager: RemoteClientProtocol {
    
    // MARK: Discogs proxy
    func getAllReleasesForUser(forceRefresh: Bool, completion: @escaping ([DCReleaseModel]) -> Void) {
        if let path = Bundle.main.url(forResource: "ShortResponse", withExtension: "json"),
            let data = try? Data(contentsOf: path, options: .dataReadingMapped),
            let model = try? JSONDecoder().decode(CollectionReleasesResponse.self,
                                                 from: data) {
            let releases = model.releases
            completion(releases)
        } else {
            completion([])
        }

    }
    
    func getDetail(for release: ReleaseViewModel) async -> DCReleaseDetailModel? {
        if let path = Bundle.main.url(forResource: "Details", withExtension: "json"),
           let data = try? Data(contentsOf: path, options: .dataReadingMapped),
           let detailArray = try? JSONDecoder().decode([DCReleaseDetailModel].self,
                                                 from: data),
           let detail = detailArray.first(where: { $0.id == release.id }) {
            return detail
        }
        
        return nil
    }
    
    func resetOauth() {
        // nothing to see here
    }
    
    // MARK: last.fm proxy
    func getLastFmUserSession(username: String, password: String, completion: @escaping ((LFSession?) -> Void)) {
        let session: LFSession = .init(subscriber: 1,
                                       name: "Test Matt",
                                       key: "12345abcde")
        
        completion(session)
    }
    
    func scrobbleRelease(_ release: ReleaseViewModel) {

    }
    
}
