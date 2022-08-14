//
//  Common.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/31/21.
//

import Foundation
import SwiftUI
import UIKit
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

// MARK: - String
extension String {
    func utf8EncodedString() -> String {
        let messageData: Data? = self.data(using: .nonLossyASCII)
        let text: String = .init(data: messageData!, encoding: .utf8) ?? ""
        return text
    }
    
    func md5String() -> String {
        let data: Data = .init(self.utf8)
        let hash: [UInt8] = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash: [UInt8] = .init(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Array
extension Array where Element: Hashable {
    var uniques: Array {
        var buffer: [Element] = []
        var added: Set<Element> = []
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}

// MARK: - Error
enum AppError: Error {
    case messageError(String)
}
