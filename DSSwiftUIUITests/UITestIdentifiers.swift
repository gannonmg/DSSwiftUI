//
//  UITestIdentifiers.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/28/21.
//

import SwiftUI

protocol UITestIdentifier {
    var identifierString: String { get }
}

extension UITestIdentifier where Self: RawRepresentable, Self.RawValue == String {
    var identifierString: String {
        "\(Self.self).\(rawValue)"
    }
}

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

extension View {
    
    func testIdentifier(_ identifier: UITestIdentifier) -> some View {
        return self.accessibilityIdentifier(identifier.identifierString)
    }
    
}
