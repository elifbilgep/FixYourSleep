//
//  TapHereAnimation.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 8.12.2024.
//

import SwiftUI

struct TapHereAnimation: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.8
    
    var body: some View {
        ZStack {
            // Outer circle
            Circle()
                .stroke(Color.white.opacity(opacity), lineWidth: 2)
                .scaleEffect(scale)
                .opacity(2 - scale)
            
            // Inner circle
            Circle()
                .fill(Color.white.opacity(opacity))  // Use same opacity
                .frame(width: 20, height: 20)
                .scaleEffect(scale * 0.8)  // Scale slightly less than outer circle
                .opacity(2 - scale)  // Use same opacity calculation
        }
        .frame(width: 30, height: 30)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                self.scale = 2.0
                self.opacity = 0
            }
        }
    }
}

