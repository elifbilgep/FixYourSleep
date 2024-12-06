//
//  WelcomeView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 3.12.2024.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var router: RouterManager
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @StateObject private var motionManager = MotionManager()
    
    var body: some View {
        ZStack {
            backgroundImage
            Color.black.opacity(0.2)
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
               headerView
                signUpButton
                signInButton
            }
            .foregroundStyle(.white)
            .padding(.bottom, 150)
     
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    var authView: some View {
        VStack {
            Spacer()
            ZStack {
                Color.blackBg
                    .ignoresSafeArea()
               
            }
            .frame(width: UIScreen.screenWidth, height: 650)
            .cornerRadius(30, corners: [.topLeft, .topRight])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var headerView: some View {
        Text("Fix your \nsleep routine")
            .font(.albertSans(.semibold, size: 48))
          
        Text("For a healtier life")
            .font(.albertSans(.regular, size: 28))
    }

    
    @ViewBuilder var signInButton: some View {
        Button {
            router.navigateTo(to: .signIn)
        } label: {
            Text("Sign In")
                .font(.albertSans(.medium, size: 16))
                .foregroundColor(.white)
                .frame(width: UIScreen.screenWidth - 48 )
                .padding(.vertical)
                .background(
                    .white.opacity(0.2)
                )
                .cornerRadius(15)
        }
        .padding(.top, 4)
    }
    
    @ViewBuilder
    private var signUpButton: some View {
        CustomButton(title: "Create Account") {
            router.navigateTo(to: .signUp)
        }
        .padding(.top, 40)
    }

    @ViewBuilder
    private var backgroundImage: some View {
        Image("space")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: UIScreen.screenWidth, maxHeight: UIScreen.screenHeight)
            .modifier(ParallaxMotionModifier(
                x: CGFloat(motionManager.x),
                y: CGFloat(motionManager.y)
            ))
            .scaleEffect(1.1) // Slightly larger to allow for movement
    }
    
    
}

#Preview {
    WelcomeView()
        .preferredColorScheme(.dark)
        .environmentObject(RouterManager())
}

