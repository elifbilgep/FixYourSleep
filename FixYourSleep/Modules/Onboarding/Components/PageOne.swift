//
//  PageOne.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 12.01.2025.
//

import SwiftUI

struct PageOne: View {
    var (primaryColor, secondaryColor) = extractDominantColors(from: "sleepyBoy")
    
    var body: some View {
        VStack(spacing: 24) {
            Image("sleepyBoy")
                .resizable()
                .scaledToFit()
                .cornerRadius(15)
                .frame(width: 350)
                .padding(.bottom, 30)
                .modifier(RotatingShadowModifier(primaryColor: primaryColor, secondaryColor: secondaryColor))
            Text("Is Social Media Keeping You Up at All Night?")
                .font(.albertSans(.bold, size: 24))
            
            Text("With this app, you can not pick up your phone at your sleep time.")
                .font(.albertSans(.regular, size: 18))
        }
        .multilineTextAlignment(.center)
        .padding(.bottom, 150)
        .frame(width: 350)
    }
}

