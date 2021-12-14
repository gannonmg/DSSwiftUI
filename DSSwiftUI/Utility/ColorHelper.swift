//
//  ColorHelper.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/14/21.
//

import SwiftUI

enum ColorName: String {
    
    case searchBackground = "searchBackground"
    
}

extension Color {
    
    init(_ colorName: ColorName) {
        self.init(colorName.rawValue)
    }
    
}
