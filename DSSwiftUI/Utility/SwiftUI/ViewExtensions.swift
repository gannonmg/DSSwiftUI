//
//  ViewExtensions.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/31/21.
//

import SwiftUI

typealias StandardAction = (() -> Void)
typealias ThrowingAction = (() throws -> Void)

// MARK: - Common
extension View {
    
    func height(_ height: CGFloat) -> some View {
        self.frame(height: height)
    }
    
    func width(_ width: CGFloat) -> some View {
        self.frame(width: width)
    }
    
    func vPrint(_ variables: Any...) -> some View {
        for variable in variables { print(variable) }
        return EmptyView()
    }
    
}

// MARK: - Progress Indicators
struct FullScreenProgressView: View {
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}
