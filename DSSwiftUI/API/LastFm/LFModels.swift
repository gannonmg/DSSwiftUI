//
//  LFModels.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/31/21.
//

import Foundation

struct LFSessionResponse: Codable {
    let session: LFSession
}

struct LFSession: Codable {
    let subscriber: Int
    let name: String
    let key: String
}
