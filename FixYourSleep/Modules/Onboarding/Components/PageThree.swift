//
//  PageThree.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 12.01.2025.
//

import SwiftUI

struct PageThree: View {
    @Binding var hasAskedForPermission: Bool
    @Binding var currentTab: Int
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Image("notification")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
            
            Text("Stay on Track")
                .font(.albertSans(.bold, size: 32))
            
            Text("Enable notifications to stay informed and track your sleep habits effortlessly.")
                .font(.albertSans(.regular, size: 20))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack {
                Image(systemName: "bell.fill")
                Text("Turn On Notifications")
                    .underline()
            }
            .onTapGesture {
                
            }
        }
        .padding(.bottom, 150)
    }
    
    //MARK: Request notification
    private func requestNotificationPermission() async {
        Task {
            hasAskedForPermission = true
            await viewModel.requestNotificationPermission {
                currentTab += 1
            }
        }
        
    }
    
}

