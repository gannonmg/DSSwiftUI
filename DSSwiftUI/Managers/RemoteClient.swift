//
//  RemoteClient.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/16/21.
//

import Foundation

protocol LastFmProxy {
    func getLastFmUserSession(username: String, password: String) async throws -> LFSession?
    func scrobbleRelease(_ release: ReleaseViewModel)
}

protocol DiscogsProxy {
    func userLoginProcess() async throws
    func getAllReleasesForUser(forceRefresh: Bool) async throws -> [DCReleaseModel]
    func getDetail(for release: ReleaseViewModel) async throws -> DCReleaseDetailModel?
    func resetOauth()
}

protocol RemoteClientProtocol: DiscogsProxy, LastFmProxy {}

final class RemoteClientManager {
    
    static var shared: RemoteClientProtocol = {
        if AppEnvironment.shared.isTesting {
            return MockRemoteClientManager.shared
        } else {
            return TrueRemoteClientManager.shared
        }
    }()
    
}

final private class TrueRemoteClientManager: RemoteClientProtocol {
    
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
    func getLastFmUserSession(username: String, password: String) async throws -> LFSession? {
        return try await LFManager.shared.getUserSession(username: username, password: password)
    }
    
    func scrobbleRelease(_ release: ReleaseViewModel) {
        LFManager.shared.scrobbleRelease(release)
    }
    
}

final private class MockRemoteClientManager: RemoteClientProtocol {
    
    static var shared: RemoteClientProtocol = MockRemoteClientManager.init()
    private init() {}

    // MARK: Discogs proxy
    func userLoginProcess() async throws {
        KeychainManager.shared.save(key: .discogsUsername, string: "gannonm")
        KeychainManager.shared.save(key: .discogsUserToken, string: "123")
        KeychainManager.shared.save(key: .discogsUserSecret, string: "456")
    }

    func getAllReleasesForUser(forceRefresh: Bool) async throws -> [DCReleaseModel] {
        if let path = Bundle.main.url(forResource: "ShortResponse", withExtension: "json") {
            let data = try Data(contentsOf: path, options: .dataReadingMapped)
            let model = try JSONDecoder().decode(CollectionReleasesResponse.self,
                                                 from: data)
            let releases = model.releases
            return releases
        } else {
            return []
        }
    }
    
    func getDetail(for release: ReleaseViewModel) async throws -> DCReleaseDetailModel? {
        if let path = Bundle.main.url(forResource: "Details", withExtension: "json") {
            let data = try Data(contentsOf: path, options: .dataReadingMapped)
            let detailArray = try JSONDecoder().decode([DCReleaseDetailModel].self,
                                                       from: data)
            let detail = detailArray.first(where: { $0.id == release.id })
            return detail
        }
        
        return nil
    }
    
    func resetOauth() {
        // nothing to see here
    }
    
    // MARK: last.fm proxy
    func getLastFmUserSession(username: String, password: String) async throws -> LFSession? {
        let session: LFSession = .init(subscriber: 1,
                                       name: "Test Matt",
                                       key: "12345abcde")
        
        return session
    }
    
    func scrobbleRelease(_ release: ReleaseViewModel) {
        // nothing to see here
    }
    
}
