//
//  UITestIdentifiers.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/28/21.
//

import SwiftUI

// MARK: - UITestIdentifier Protocol
protocol UITestIdentifier where Self: RawRepresentable, Self.RawValue: StringProtocol {
    var identifierString: String { get }
}

extension UITestIdentifier {
    var identifierString: String {
        "\(Self.self).\(rawValue)"
    }
}

// MARK: - Screen Identifiers
enum LoginIdentifier: String, UITestIdentifier {
    case loginButton
}

enum ReleaseListIdentifier: String, UITestIdentifier {
    case settingsButton,
         shuffleButton,
         filterButton,
         releaseList
}

enum ReleaseDetailIdentifier: String, UITestIdentifier {
    case scrobbleButton
}

enum LastFmIdentifier: String, UITestIdentifier {
    case usernameField,
         passwordField,
         loginButton
}
