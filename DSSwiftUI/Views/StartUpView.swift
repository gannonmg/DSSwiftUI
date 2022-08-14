//
//  StartUpView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 8/14/22.
//

import Combine
import SwiftUI

struct StartUpView: View {
    
    @State private var animateGradient: Bool = false
    
    @State private var startX: CGFloat = 0
    @State private var startY: CGFloat = 0.9
    @State private var endX: CGFloat = 0
    @State private var endY: CGFloat = 1

    let darkGray: Color = Color(uiColor: .darkGray)
    
    var body: some View {
        VStack {
            LinearGradient(
                colors: [darkGray, .white, darkGray],
                startPoint: .init(x: startX, y: startY),
                endPoint: .init(x: endX, y: endY)
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2)
                    .repeatForever()
                ) {
                    startX = 1
                    startY = 0
                }
                withAnimation(
                    .easeInOut(duration: 2)
                    .repeatForever()
                ) {
                    endX = 1
                    endY = 0
                }
            }
            .mask {
                Text("Vinyl\n    Space")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }
}

struct StartUpView_Previews: PreviewProvider {
    static var previews: some View {
        StartUpView()
    }
}
