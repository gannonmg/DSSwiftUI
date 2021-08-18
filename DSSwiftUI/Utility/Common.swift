//
//  Common.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/31/21.
//

import Foundation
import SwiftUI
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

//MARK: - String
extension String {
    
    var words:[String] { self.split(separator: " ").map { String($0) } }
    
    var trimmingWhitespaces: String { self.trimmingCharacters(in: .whitespacesAndNewlines) }
    
    //LastFM signature encryption
    func utf8DecodedString() -> String {
        let data = self.data(using: .utf8)
        let message = String(data: data!, encoding: .nonLossyASCII) ?? ""
        return message
    }
    
    func utf8EncodedString() -> String {
        let messageData = self.data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8) ?? ""
        return text
    }
    
    func md5String() -> String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
}

//MARK: - Collection
extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

//MARK: - Array
extension Array where Element: Equatable {
    
    ///Returns whether or not the current array contains all elements of the provided array.
    func contains(array: [Element]) -> Bool {
        for item in array {
            if !self.contains(item) { return false }
        }
        return true
    }
    
    ///Returns whether or not the current array contains at least one item of the provided array.
    func containsMatch(from array: [Element]) -> Bool {
        for item in array {
            if self.contains(item) { return true }
        }
        return false
    }
}

extension Array where Element: Hashable {
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}

//MARK: - Color
extension Color {
    
    static let navBar = Color(hex: 0x000009)
    static let backgroundColor = Color(hex: 0x22242E)
    static let textPrimary = Color(hex: 0xEDEEE5)
    static let textSecondary = Color(hex: 0x94969C)
    static let separator = Color(hex: 0x484D5B)

    init(hex: UInt, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >> 08) & 0xff) / 255,
                  blue: Double((hex >> 00) & 0xff) / 255,
                  opacity: alpha)
    }
    
}

