//
//  KeychainManager.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 9/8/21.
//
//  Adapted from https://stackoverflow.com/a/37539998/11556801
//

import Foundation
import Security

class KeychainManager {
    
    enum KeychainKey: String {
        case discogsUserToken, discogsUserSecret, discogsUsername, lastFmSessionKey, testKey
    }
    
    static let shared = KeychainManager()
    private init() {}
    
    func save(key: KeychainKey, string: String) {
        guard let data = string.data(using: .utf8) else { return }
        save(key: key.rawValue, data: data)
    }
    
    func get(for key: KeychainKey) -> String? {
        guard let data = load(key: key.rawValue) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func remove(key: KeychainKey) {
        remove(key: key.rawValue)
    }

    @discardableResult
    private func save(key: String, data: Data) -> OSStatus {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                    kSecAttrAccount as String: key,
                                    kSecValueData as String: data]
        
        SecItemDelete(query as CFDictionary)
        
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    private func load(key: String) -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne]

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
    
    private func remove(key: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key]

        // Delete any existing items
        let status = SecItemDelete(query as CFDictionary)
//        switch status {
//        case errSecSuccess:
//            print("Successfully removed key \(key)")
//        case let err as SecCopyErrorMessageString(status, nil):
//            print("Remove failed for key \(key): \(err)")
//        default:
//            print("Remove failed for key \(key)")
//        }
        if status == errSecSuccess {
            print("Successfully removed key \(key)")
        } else if let err = SecCopyErrorMessageString(status, nil) {
            print("Remove failed for key \(key): \(err)")
        } else {
            print("Remove failed for key \(key)")
        }
    }
    
}

extension Data {

    init<T>(from value: T) {
        self = withUnsafePointer(to: value) { (ptr: UnsafePointer<T>) -> Data in
            return Data(buffer: UnsafeBufferPointer(start: ptr, count: 1))
        }
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}
