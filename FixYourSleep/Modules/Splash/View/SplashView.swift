//
//  SplashView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 3.12.2024.
//
import SwiftUI

struct Star: Identifiable {
    let id = UUID()
    let position: CGPoint
    var brightness: Double
}

struct SplashView: View {
    @EnvironmentObject var userStateManager: UserStateManager
    @EnvironmentObject var router: RouterManager
    @State private var textOpacity = 0.0
    @StateObject private var viewModel: SplashViewModel
    
    @State private var stars = (0...80).map { _ in
        Star(
            position: CGPoint(
                x: CGFloat.random(in: 20...UIScreen.screenWidth-20),
                y: CGFloat.random(in: 20...UIScreen.screenHeight-20)
            ),
            brightness: 0
        )
    }
    
    init(viewModel: SplashViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1C1B3A"),
                    Color(hex: "3F3E54")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            ForEach(stars) { star in
                Circle()
                    .fill(.white)
                    .frame(width: 3, height: 3)
                    .position(star.position)
                    .opacity(star.brightness)
                    .blur(radius: 0.5)
            }
            VStack {
                Image("logo")
                    .scaleEffect(0.8)
                Text("Fix Your Sleep")
                    .font(.albertSans(.regular, size: 15))
                    .foregroundStyle(.white)
                    .opacity(textOpacity)
                    .offset(y: -40)
            }
            
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
        .ignoresSafeArea()
        .onAppear {
            //            Task {
            //              try? await viewModel.signOut()
            //            }
            animateStars()
            animateText()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                checkUser()
            }
            
            
            
        }
        
    }
    
    private func animateStars() {
        for index in stars.indices {
            withAnimation(
                Animation
                    .easeInOut(duration: Double.random(in: 3...5))
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...3))
            ) {
                stars[index].brightness = Double.random(in: 0.3...0.8)
            }
        }
    }
    
    private func animateText() {
        withAnimation(
            .easeIn(duration: 1.0)
            .delay(2.0)
        ) {
            textOpacity = 1.0
        }
    }
    
    private func checkUser() {
        if userStateManager.authState == .signedIn {
            if let user = userStateManager.user {
                Task {
                    if let fetchedUser =
                        await viewModel.fetchUserIfAvailable(with: user.uid) {
                        router.navigateTo(to: .home)
                        userStateManager.fysUser = fetchedUser
                    } else {
                        router.navigateTo(to: .welcome)
                        Task {
                          try await viewModel.signOut()
                        }
                    }
                }
            }
        } else {
            router.navigateTo(to: .welcome)
        }
    }
}
