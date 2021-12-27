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

extension NSNotification.Name {
    static let keychainUpdated: NSNotification.Name = .init("keychainUpdated")
}

class KeychainManager {
    
    enum KeychainKey: String, CaseIterable {
        case discogsUserToken, discogsUserSecret, discogsUsername, lastFmSessionKey, testKey
    }
    
    static let shared = KeychainManager()
    private init() {}
    
    func save(key: KeychainKey, string: String) {
        guard let data = string.data(using: .utf8) else { return }
        save(key: key.rawValue, data: data)
        NotificationCenter.default.post(name: .keychainUpdated, object: nil)
    }
    
    func get(for key: KeychainKey) -> String? {
        guard let data = load(key: key.rawValue) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func remove(key: KeychainKey) {
        remove(key: key.rawValue)
        NotificationCenter.default.post(name: .keychainUpdated, object: key.rawValue)
    }
    
    func clearAll() {
        KeychainKey.allCases.forEach { remove(key: $0) }
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
