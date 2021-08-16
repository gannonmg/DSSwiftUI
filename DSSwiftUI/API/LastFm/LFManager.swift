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
    
    //MARK: Variables
    let baseRequestUrl = URL(string: "https://ws.audioscrobbler.com/2.0/")!
    
    lazy var session:URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        return URLSession(configuration: configuration)
    }()
    
    //MARK: Parameter building for calls
    func getApiSignature(from params: [String:Any]) -> String {
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
    
    ///All calls to last.fm require an api_sig of alphabetized parameters and
    func getQueryItems(from params: [String:Any], format: ResponseFormat = .json) -> [URLQueryItem] {
        var queryItems:[URLQueryItem] = []
        
        for (k, v) in params {
            queryItems.append(.init(name: k, value: "\(v)"))
        }
        
        queryItems.append(.init(name: "api_sig", value: getApiSignature(from: params)))
        queryItems.append(.init(name: "format", value: format.rawValue))
        return queryItems
    }
    
    //MARK: Login
    func getUserSession(username: String, password: String, completion: @escaping((LFSession?)->Void)) {
        
        let authParams:[String:String] = ["api_key":  LFAuthInfo.apiKey,
                                          "method":   LFMethod.auth.method,
                                          "password": password,
                                          "username": username]
        
        var request = URLRequest(url: baseRequestUrl)
        request.httpMethod = HTTPMethod.post.method
        
        var urlComponents = URLComponents(url: baseRequestUrl, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = getQueryItems(from: authParams)
        request.url = urlComponents.url
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                let session = try? JSONDecoder().decode(LFSessionResponse.self, from: data)
                completion(session?.session)
            } else {
                print("Data \(String(describing: data))")
                print("Response \(String(describing: response))")
                print("Error \(String(describing: error))")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    //MARK: Scrobbling
    func scrobbleTrack(album: String, artist: String, track: String, timestamp: TimeInterval, key: String) {
        
        let params:[String:Any] = ["api_key":   LFAuthInfo.apiKey,
                                   "method":    LFMethod.scrobble.method,
                                   "sk":        key,
                                   "artist":    artist,
                                   "album":     album,
                                   "track":     track,
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
