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

// MARK: - Array
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

// MARK: - URL
extension URL {
    init?(optionalString: String?) {
        guard let string = optionalString else {
            return nil
        }
        
        self.init(string: string)
    }
}

// MARK: - Error
enum AppError: Error {
    case messageError(String)
}
