//
//  LFManager.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/31/21.
//

import Foundation

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
    static let shared = LFManager()
    
    // MARK: Variables
    private let baseRequestUrl = URL(string: "https://ws.audioscrobbler.com/2.0/")!
    
    lazy private var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        return URLSession(configuration: configuration)
    }()
    
    // MARK: Parameter building for calls
    private func getApiSignature(from params: [String: Any]) -> String {
        var alphabetizedParams = ""
        let sortedKeys = params.keys.sorted(by: <)
        sortedKeys.forEach { key in
            guard let value = params[key] else { return }
            alphabetizedParams += "\(key)\(value)"
        }
        
        let utf8EncodedStr = alphabetizedParams.utf8EncodedString()
        let secretAppended = utf8EncodedStr + LFAuthInfo.apiSecret
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
    func getUserSession(username: String, password: String) async -> LFSession? {
        
        let authParams: [String: String] = ["api_key": LFAuthInfo.apiKey,
                                            "method": LFMethod.auth.method,
                                            "password": password,
                                            "username": username]
        
        var request = URLRequest(url: baseRequestUrl)
        request.httpMethod = HTTPMethod.post.method
        
        var urlComponents = URLComponents(url: baseRequestUrl, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = getQueryItems(from: authParams)
        request.url = urlComponents.url
        
        return await withCheckedContinuation { continuation in
            let task = session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    print(String(decoding: data, as: UTF8.self))
                    let session = try? JSONDecoder().decode(LFSessionResponse.self, from: data)
                    continuation.resume(returning: session?.session)
                } else {
                    print("Data \(String(describing: data))")
                    print("Response \(String(describing: response))")
                    print("Error \(String(describing: error))")
                    continuation.resume(returning: nil)
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: Scrobbling
    func scrobbleRelease(_ release: ReleaseViewModel) {
        let tracklist = release.tracklist
        guard !release.tracklist.isEmpty,
              let key = KeychainManager.shared.get(for: .lastFmSessionKey)
        else { return }
        
        var timestamp = Date.now.timeIntervalSince1970
        for track in tracklist {
            scrobbleTrack(album: release.title,
                          artist: release.artists.first?.name ?? "",
                          track: track.title,
                          timestamp: timestamp,
                          key: key)
            
            // If unable to get track duration (not always available in discogs data)
            // set to three minutes
            let trackLength = Double(track.duration) ?? 180
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
        
        var request = URLRequest(url: baseRequestUrl)
        request.httpMethod = HTTPMethod.post.method
        
        var urlComponents = URLComponents(url: baseRequestUrl, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = getQueryItems(from: params)
        request.url = urlComponents.url
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
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
