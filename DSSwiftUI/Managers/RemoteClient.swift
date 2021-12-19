//
//  RemoteClient.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/16/21.
//

import Foundation

protocol LastFmProxy {
    func getLastFmUserSession(username: String, password: String) async -> LFSession?
    func scrobbleRelease(_ release: ReleaseViewModel)
}

protocol DiscogsProxy {
    func userLoginProcess() async throws
    func getAllReleasesForUser(forceRefresh: Bool) async throws -> [DCReleaseModel]
    func getDetail(for release: ReleaseViewModel) async throws -> DCReleaseDetailModel?
    func resetOauth()
}

protocol RemoteClientProtocol: DiscogsProxy, LastFmProxy {}

#if TEST
let RemoteClientManager: RemoteClientProtocol = MockRemoteClientManager.shared
#else
let RemoteClientManager: RemoteClientProtocol = TrueRemoteClientManager.shared
#endif

final fileprivate class TrueRemoteClientManager: RemoteClientProtocol {
    
    static var shared: RemoteClientProtocol = TrueRemoteClientManager.init()
    private init() {}

    // MARK: Discogs proxy
    func userLoginProcess() async throws {
        try await DCManager.shared.userLoginProcess()
    }

    func getAllReleasesForUser(forceRefresh: Bool) async throws -> [DCReleaseModel] {
        return try await DCManager.shared.getAllReleasesForUser(forceRefresh: forceRefresh)
    }
    
    func getDetail(for release: ReleaseViewModel) async throws -> DCReleaseDetailModel? {
        return try await DCManager.shared.getDetail(for: release.resourceURL)
    }
    
    func resetOauth() {
        DCManager.shared.resetOauth()
    }
    
    // MARK: last.fm proxy
    func getLastFmUserSession(username: String, password: String) async -> LFSession? {
        return await LFManager.shared.getUserSession(username: username, password: password)
    }
    
    func scrobbleRelease(_ release: ReleaseViewModel) {
        LFManager.shared.scrobbleRelease(release)
    }
    
}

final fileprivate class MockRemoteClientManager: RemoteClientProtocol {
    
    static var shared: RemoteClientProtocol = MockRemoteClientManager.init()
    private init() {}

    // MARK: Discogs proxy
    func userLoginProcess() async throws {
        // What to do here
    }

    func getAllReleasesForUser(forceRefresh: Bool) async throws -> [DCReleaseModel] {
        if let path = Bundle.main.url(forResource: "ShortResponse", withExtension: "json"),
            let data = try? Data(contentsOf: path, options: .dataReadingMapped),
            let model = try? JSONDecoder().decode(CollectionReleasesResponse.self,
                                                 from: data) {
            let releases = model.releases
            return releases
        } else {
            return []
        }
    }
    
    func getDetail(for release: ReleaseViewModel) async throws -> DCReleaseDetailModel? {
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
    func getLastFmUserSession(username: String, password: String) async -> LFSession? {
        let session: LFSession = .init(subscriber: 1,
                                       name: "Test Matt",
                                       key: "12345abcde")
        
        return session
    }
    
    func scrobbleRelease(_ release: ReleaseViewModel) {
        // nothing to see here
    }
    
}