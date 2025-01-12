//
//  PageTwo.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 12.01.2025.
//

import SwiftUI

struct PageTwo: View {
    var (primaryColor, secondaryColor) = extractDominantColors(from: "onboarding-2")
    
    var body: some View {
        VStack(spacing: 24) {
            Image("onboarding-2")
                .resizable()
                .scaledToFill()
                .frame(width: 350, height: 200)
                .clipped()
                .cornerRadius(15)
                .padding(.bottom, 30)
                .modifier(RotatingShadowModifier(primaryColor: primaryColor, secondaryColor: secondaryColor))
            Text("You can't pick up the phone")
                .font(.albertSans(.bold, size: 24))
            Text("The rule is simple, you can not\npick up your phone after your sleep goal time.")
                .font(.albertSans(.regular, size: 18))
        }
        .multilineTextAlignment(.center)
        .padding(.bottom, 150)
        .frame(width: 350)
    }
}


