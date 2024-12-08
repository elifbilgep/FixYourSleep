//
//  OnboardingView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 5.12.2024.
//

import SwiftUI
struct OnboardingView: View {
    @State private var selectedDate = Date()
    @State private var showTimePicker = false
    @State private var offset: CGFloat = 0
    @StateObject private var motionManager = MotionManager()
    @EnvironmentObject private var router: RouterManager
    @StateObject private var viewModel: OnboardingViewModel
    @EnvironmentObject private var userStateManager: UserStateManager
    
    init(onboardingViewModel: OnboardingViewModel) {
        _viewModel = StateObject(wrappedValue: onboardingViewModel)
    }
    
    private var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            backgroundImage
            VStack(spacing: 100) {
                VStack(alignment: .leading) {
                    Text("When do\nyou want to\nsleep?")
                        .font(.albertSans(.semibold, size: 48))
                        .padding(.leading, 20)
                   
                }
                .frame(width: UIScreen.screenWidth, alignment: .leading)
                
                HStack {
                    Spacer()
                    Text(timeFormatter.string(from: selectedDate))
                        .font(.albertSans(.semibold, size: 64))
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showTimePicker = true
                                offset = 0
                            }
                        }
                    Spacer()
                }
                
                CustomButton(title: "Continue") {
                    handleContinue()
                }
             
            }
            .frame(width: 300)
            .foregroundStyle(.white)
            
            if showTimePicker {
                timePickerView
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
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
                Text(error.localizedDescription)
            }
        }
        .onAppear {

//            print("onboarrding view fysuser:", userStateManager.fysUser?.id)
//            print("onboarrding view user:", userStateManager.user?.uid)
        }
    }
    
    private func handleContinue() {
        Task {
            // Update the user's sleep time
            if let user = userStateManager.fysUser {
                print("🧠 there fyu user")
                await viewModel.updateGoalSleepingTime(
                    for: user,
                    newTime: timeFormatter.string(from: selectedDate)
                )
            } else {
                print("🧠 there no fyu user")
            }
            // Only navigate if there was no error
            if viewModel.error == nil {
                await MainActor.run {
                    router.navigateTo(to: .splash)
                }
            }
        }
    }
    
    private func dismissPicker() {
        withAnimation(.spring()) {
            offset = UIScreen.main.bounds.height
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showTimePicker = false
                offset = 0
            }
        }
    }
    
    @ViewBuilder
    private var timePickerView: some View {
        // Semi-transparent background
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .opacity(1 - (abs(offset) / 300.0))
            .onTapGesture {
                dismissPicker()
            }
        
        // Time Picker
        VStack {
            HStack {
                Button("Cancel") {
                    dismissPicker()
                }
                Spacer()
                Button("Done") {
                    dismissPicker()
                }
            }
            .padding()
            .foregroundColor(.white)
            
            DatePicker("Select Time",
                      selection: $selectedDate,
                      displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
        }
        .background(RoundedRectangle(cornerRadius: 16)
            .fill(Color.darkGray))
        .offset(y: offset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.height > 0 {
                        offset = gesture.translation.height
                    }
                }
                .onEnded { gesture in
                    if gesture.translation.height > 100 {
                        dismissPicker()
                    } else {
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }
                }
        )
        .padding()
        .transition(.move(edge: .bottom))
        .tint(.white)
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
            .scaleEffect(1.1)
            .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
    }
}
