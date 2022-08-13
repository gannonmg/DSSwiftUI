//
//  LFManager.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/31/21.
//

import Foundation
import MGKeychain

enum HTTPMethod {
    case get, post

    var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
}

enum ResponseFormat: String {
    case json
}

enum LFMethod {
    
    case auth, scrobble
    
    var method: String {
        switch self {
        case .auth: return "auth.getMobileSession"
        case .scrobble: return "track.scrobble"
        }
    }
    
}

class LFManager {
    
    private init() {}
    static let shared: LFManager = .init()
    
    // MARK: Variables
    private let baseRequestUrl: URL = .init(string: "https://ws.audioscrobbler.com/2.0/")!
    
    lazy private var session: URLSession = {
        let configuration: URLSessionConfiguration = .default
        configuration.timeoutIntervalForRequest = 10
        return URLSession(configuration: configuration)
    }()
    
    // MARK: Parameter building for calls
    private func getApiSignature(from params: [String: Any]) -> String {
        var alphabetizedParams: String = ""
        let sortedKeys: [String] = params.keys.sorted(by: <)
        sortedKeys.forEach { key in
            guard let value = params[key] else { return }
            alphabetizedParams += "\(key)\(value)"
        }
        
        let utf8EncodedStr: String = alphabetizedParams.utf8EncodedString()
        let secretAppended: String = utf8EncodedStr + LFAuthInfo.apiSecret
        return secretAppended.md5String()
    }
    
    /// All calls to last.fm require an api_sig of alphabetized parameters and
    private func getQueryItems(from params: [String: Any], format: ResponseFormat = .json) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        
        for (key, value) in params {
            queryItems.append(.init(name: key, value: "\(value)"))
        }
        
        queryItems.append(.init(name: "api_sig", value: getApiSignature(from: params)))
        queryItems.append(.init(name: "format", value: format.rawValue))
        return queryItems
    }
    
    // MARK: Login
    func getUserSession(username: String, password: String) async throws -> LFSession {
        
        let authParams: [String: String] = ["api_key": LFAuthInfo.apiKey,
                                            "method": LFMethod.auth.method,
                                            "password": password,
                                            "username": username]
        
        var request: URLRequest = .init(url: baseRequestUrl)
        request.httpMethod = HTTPMethod.post.method
        
        var urlComponents: URLComponents = .init(url: baseRequestUrl, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = getQueryItems(from: authParams)
        request.url = urlComponents.url
        
        return try await withCheckedThrowingContinuation { continuation in
            let task: URLSessionDataTask = session.dataTask(with: request) { (data, _, error) in
                do {
                    if let data: Data = data {
                        let session: LFSessionResponse = try JSONDecoder().decode(LFSessionResponse.self, from: data)
                        continuation.resume(returning: session.session)
                    } else if let error: Error = error {
                        continuation.resume(throwing: error)
                    } else {
                        let error: Error = AppError.messageError("LFSession failed without error")
                        continuation.resume(throwing: error)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: Scrobbling
    func scrobbleRelease(_ release: ReleaseViewModel) {
        let tracklist: [DCTrackModel] = release.tracklist
        guard !release.tracklist.isEmpty,
              let key = KeychainManager.shared.get(for: .lastFmSessionKey)
        else { return }
        
        var timestamp: TimeInterval = Date.now.timeIntervalSince1970
        for track in tracklist {
            scrobbleTrack(album: release.title,
                          artist: release.artists.first?.name ?? "",
                          track: track.title,
                          timestamp: timestamp,
                          key: key)
            
            // If unable to get track duration (not always available in discogs data)
            // set to three minutes
            let trackLength: Double = .init(track.duration) ?? 180
            timestamp += trackLength
        }
    }
    
    private func scrobbleTrack(album: String, artist: String, track: String, timestamp: TimeInterval, key: String) {
        
        let params: [String: Any] = ["api_key": LFAuthInfo.apiKey,
                                     "method": LFMethod.scrobble.method,
                                     "sk": key,
                                     "artist": artist,
                                     "album": album,
                                     "track": track,
                                     "timestamp": "\(timestamp)"]
        
        var request: URLRequest = .init(url: baseRequestUrl)
        request.httpMethod = HTTPMethod.post.method
        
        var urlComponents: URLComponents = .init(url: baseRequestUrl, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = getQueryItems(from: params)
        request.url = urlComponents.url
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            if let data: Data = data {
                print("Got data")
                print(String(decoding: data, as: UTF8.self))
            } else {
                print("Did not get data")
                print("Data \(String(describing: data))")
                print("Response \(String(describing: response))")
                print("Error \(String(describing: error))")
            }
            
        }
        
        task.resume()
    }
    
}
