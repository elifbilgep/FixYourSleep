//
//  OnboardingView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 5.12.2024.
//

import SwiftUI
struct OnboardingView: View {
    //MARK: Properties
    @EnvironmentObject private var router: RouterManager
    @EnvironmentObject private var userStateManager: UserStateManager
    
    @AppStorage(AppStorageKeys.isFirstTime) private var isFirstTime: Bool = true
    @AppStorage(AppStorageKeys.bedTimeGoal) private var bedTimeGoal = "00:00"
    @AppStorage(AppStorageKeys.wakeTimeGoal) private var wakeTimeGoal = "09:00"
    @AppStorage(AppStorageKeys.username) private var username = ""
    
    @StateObject private var motionManager = MotionManager()
    @StateObject private var viewModel: OnboardingViewModel
    
    @State private var hasAskedForPermission = false
    @State private var wakeUpTime = Date()
    @State private var showWakeUpPicker = false
    @State private var bedTime = Date()
    @State private var showTimePicker = false
    @State private var currentTab = 0
    
    //MARK: Init
    init(viewModel: OnboardingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: body
    var body: some View {
        ZStack {
            Color.blackBackgroundColor
            TabView(selection: $currentTab) {
                PageOne()
                    .tag(0)
                PageTwo()
                    .tag(1)
                PageThree(
                    hasAskedForPermission: $hasAskedForPermission,
                    currentTab: $currentTab,
                    viewModel: viewModel)
                .tag(2)
                PageFour(
                    bedTime: $bedTime,
                    wakeUpTime: $wakeUpTime,
                    showTimePicker: $showTimePicker,
                    showWakeUpPicker: $showWakeUpPicker
                )
                .tag(3)
            }
            .tabViewStyle(.page)
            .padding(.bottom)
            
            if currentTab < 3 {
                CustomButton(title: "Next") {
                    handleNextButton()
                }
                .offset(y: 300)
            }
            else if currentTab == 3 {
                CustomButton(title: "Get Started") {
                    handleContinue()
                    isFirstTime = false
                }
                .offset(y: 300)
            }
            if showTimePicker {
                CustomTimePickerView(
                    isPresented: $showTimePicker,
                    selectedDate: $bedTime
                )
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .opacity(0.5)
            }
                
            
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .alert("Error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
    }
    
    //MARK: Handle Next Button
    private func handleNextButton() {
        if currentTab == 2 && !viewModel.notificationManager.isNotificationsEnabled && !hasAskedForPermission {
            Task {
                await viewModel.requestNotificationPermission(onGranted: {
                    currentTab += 1
                })
            }
        } else {
            withAnimation {
                currentTab += 1
            }
        }
    }
    
    //MARK: Handle Continue
    private func handleContinue() {
        Task {
            guard let user = userStateManager.user else {
                viewModel.error = "User not found"
                return
            }
            
            bedTimeGoal = bedTime.dateToHHMM()
            wakeTimeGoal = wakeUpTime.dateToHHMM()
            
            let newFYUser = FYSUser(
                id: user.uid,
                userName: username,
                email: user.email ?? "",
                bedTime: bedTimeGoal,
                wakeTime: wakeTimeGoal,
                notificationTime: nil,
                isAlarmEnabled: false,
                isNotificationEnabled: viewModel.notificationManager.isNotificationsEnabled,
                sleepData: nil
            )
            
            do {
                try await viewModel.createNewUserForMailSignUp(user: newFYUser)
                
                await MainActor.run {
                    router.navigateTo(to: .splash)
                }
            } catch {
                await MainActor.run {
                    viewModel.error = error.localizedDescription
                }
            }
        }
    }
}

