//
//  ColorHelper.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/14/21.
//

import SwiftUI

// From: https://stackoverflow.com/a/62207329/11556801
extension Color {
    #if os(macOS)
    static let background: Color = .init(NSColor.windowBackgroundColor)
    static let secondaryBackground: Color = .init(NSColor.underPageBackgroundColor)
    static let tertiaryBackground: Color = .init(NSColor.controlBackgroundColor)
    #else
    static let background: Color = .init(UIColor.systemBackground)
    static let secondaryBackground: Color = .init(UIColor.secondarySystemBackground)
    static let tertiaryBackground: Color = .init(UIColor.tertiarySystemBackground)
    #endif
}
