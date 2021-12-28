//
//  UITestable.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/28/21.
//

import SwiftUI

//MARK: - UITestable Protocol
protocol UITestable: View {
    associatedtype IdentifierEnum: UITestIdentifier
}

extension View {
    func testIdentifier<T: UITestIdentifier>(_ identifier: T) -> some View {
        accessibilityIdentifier(identifier.identifierString)
    }
}
