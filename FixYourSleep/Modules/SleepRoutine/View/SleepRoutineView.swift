//
//  SlepView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 8.12.2024.
//

import SwiftUI

struct SleepRoutineView: View {
    @EnvironmentObject private var userStateManager: UserStateManager
    @State private var currentStep = 0
    @StateObject private var viewModel: SleepRoutineViewModel
    @AppStorage("isFirstTime") private var isFirstTime: Bool = true
    @State private var isSheetPresented = false
    @AppStorage(AppStorageKeys.isSleepingRightNow) private var isSleepingRightNow: Bool = false
    @EnvironmentObject private var router: RouterManager
    
    init(viewModel: SleepRoutineViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color.blackBg
            VStack {
                progressView
                titleView
                tasksView
                Spacer()
                CustomButton(title: "Continue") {
                    isSheetPresented = true
                }
                .padding(.bottom, 150)
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $isSheetPresented) {
            sheetView
        }
    }
    
    //MARK: Progress View
    @ViewBuilder
    private var progressView: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                RoundedRectangle(cornerRadius: 10)
                    .fill(index <= currentStep-1 ? Color.customAccentLight : Color.gray)
                    .frame(height: 10)
                
            }
        }
        .padding()
        .padding(.top, 80)
    }
    
    //MARK: Title View
    @ViewBuilder
    private var titleView: some View {
        VStack(alignment: .leading) {
            Text("Prepare for sleep")
                .font(.albertSans(.bold, size: 32))
            Text("Goal: Sleeping at \(userStateManager.fysUser?.bedTime ?? "00:00")")
                .font(.albertSans(.semibold, size: 20))
        }
        .padding(.horizontal)
        .frame(width: UIScreen.screenWidth, alignment: .leading)
        
    }
    
    //MARK: Tasks View
    @ViewBuilder
    private var tasksView: some View {
        ForEach($viewModel.steps) { $step in
            HStack {
                StatusDotView(isCompleted: step.isCompleted)
                Text(step.stepTitle)
                    .foregroundColor(.white)
                Spacer()
                ZStack {
                    if viewModel.steps.firstIndex(where: { $0.id == step.id }) == currentStep {
                        Image(systemName: "chevron.forward")
                        
                        if isFirstTime {
                            TapHereAnimation()
                        }
                    }
                }
            }
            .onTapGesture {
                if viewModel.steps.firstIndex(where: { $0.id == step.id }) == currentStep {
                    isSheetPresented = true
                    isFirstTime = false
                }
            }
            .padding(.horizontal)
            .frame(width: UIScreen.screenWidth, height: 20)
        }
        .padding(.top)
    }
    
    //MARK: Sheet View
    @ViewBuilder
    private var sheetView: some View {
        if currentStep == 0 {
            focusView
                .frame(width: 500)
                .presentationDetents([.height(500)])
                .interactiveDismissDisabled()
        } else if currentStep == 1 {
            relaxView
                .frame(width: 400)
                .presentationDetents([.height(400)])
                .interactiveDismissDisabled(true)  // Already exists for timer
        } else if currentStep == 2 {
            putYourPhoneAway
                .frame(width: 400)
                .presentationDetents([.height(500)])
                .interactiveDismissDisabled()
        }
    }
    
    //MARK: focus sheet view
    @ViewBuilder
    private var focusView: some View {
        VStack(spacing: 24) {
            // Header
            VStack {
                Text("Change focus mode")
                    .font(.albertSans(.semibold, size: 28))
                Text("To sleep, so do not get any notifications that disturb you")
                    .frame(width: 350, height: 50)
                    .font(.albertSans(.regular, size: 18))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 30)
            
            // Moon Icon
            Circle()
                .fill(Color.customAccent.opacity(0.2))
                .frame(width: 70, height: 70)
                .overlay {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.customAccent)
                }
                .padding(10)
            
            // Instructions
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.customAccent)
                        .frame(width: 24, height: 24)
                        .overlay {
                            Text("1")
                                .font(.albertSans(.semibold, size: 14))
                                .foregroundColor(.white)
                        }
                    Text("Swipe down from top right corner")
                        .font(.albertSans(.regular, size: 16))
                }
                
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.customAccent)
                        .frame(width: 24, height: 24)
                        .overlay {
                            Text("2")
                                .font(.albertSans(.semibold, size: 14))
                                .foregroundColor(.white)
                        }
                    Text("Tap Focus")
                        .font(.albertSans(.regular, size: 16))
                }
                
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.customAccent)
                        .frame(width: 24, height: 24)
                        .overlay {
                            Text("3")
                                .font(.albertSans(.semibold, size: 14))
                                .foregroundColor(.white)
                        }
                    Text("Select Sleep mode")
                        .font(.albertSans(.regular, size: 16))
                }
            }
            
            CustomButton(title: "Done") {
                withAnimation {
                    currentStep += 1
                    viewModel.completeStepAndAddNext(0)
                }
                isSheetPresented = false
            }
            .padding(.vertical)
        }
    }
    
    //MARK: Relax your mind
    @ViewBuilder
    private var relaxView: some View {
        VStack {
            // Header
            VStack {
                Text("I will be waiting...")
                    .font(.albertSans(.semibold, size: 28))
                    .frame(width: 350, height: 30)
                    .padding(.bottom)
                Text("I'll be here for the next 10 minutes. Take this time to read a book and unwind before bed.")
                    .font(.albertSans(.regular, size: 16))
                    .frame(width: 350, height: 60)
                    .multilineTextAlignment(.center)
            }
            
            // Timer Text
            Text(viewModel.formatTime())
                .font(.system(size: 64, weight: .bold))
            
            // Buttons
            VStack(spacing: 16) {
                if viewModel.timeRemaining == 0 {
                    CustomButton(title: "Continue") {
                        withAnimation {
                            currentStep += 1
                            viewModel.completeStepAndAddNext(1)
                        }
                        isSheetPresented = false
                    }
                } else if !viewModel.isTimerRunning {
                    VStack(spacing: 20) {
                        CustomButton(title: "Start timer") {
                            withAnimation {
                                viewModel.startTimer()
                            }
                        }
                        Text("Cancel the sleep")
                            .foregroundStyle(.red)
                            .font(.albertSans(.regular, size: 16))
                            .onTapGesture {
                                cancelTheSleep()
                            }
                    }
                    
                } else {
                    Button(action: {
                        withAnimation {
                            viewModel.stopTimer()
                            viewModel.timeRemaining = 600
                        }
                    }) {
                        Text("Cancel Timer")
                            .foregroundColor(.red)
                            .font(.albertSans(.semibold, size: 16))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                    }
                }
            }
        }
        .frame(width: 350)
        .interactiveDismissDisabled(viewModel.isTimerRunning)
        .onDisappear {
            if !viewModel.isTimerRunning {
                viewModel.timeRemaining = 600
            }
        }
    }
    
    //MARK: Put Phone Away View
    @ViewBuilder
    private var putYourPhoneAway: some View {
        VStack(spacing: 24) {
            // Header
            VStack {
                Text("Put the phone far away")
                    .font(.albertSans(.semibold, size: 28))
                Image("phoneOnTable")
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical, 4)
                    .cornerRadius(15)
                Text("After 3 minutes, I'll start monitoring your phone's movement. Any phone activity will indicate you're not sleeping.")
                    .font(.albertSans(.regular, size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }
            .padding(.vertical)
            
            CustomButton(title: "I understand") {
                viewModel.completeStepAndAddNext(2)
                isSheetPresented = false
                isSleepingRightNow = true
                withAnimation(.easeInOut(duration: 1)) {
                    router.navigateTo(to: .home)
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal)
        .frame(width: 350)
    }
    
    private func cancelTheSleep() {
        isSheetPresented = false
        router.navigateTo(to: .home)
    }
}

//MARK: Step
struct Step: Identifiable {
    var id: String = UUID().uuidString
    var stepTitle: String
    var isCompleted: Bool
}

//MARK: Status Dot View
struct StatusDotView: View {
    let isCompleted: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isCompleted ? Color.customAccent : Color.customGray)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.5), lineWidth: 1)
                        .blur(radius: 1)
                        .offset(y: 1)
                        .mask {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    colors: [.black.opacity(0.6), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom))
                        }
                }
                .overlay {
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
        }
        .frame(width: 24, height: 24)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
                .blur(radius: 1)
                .offset(y: 1)
        }
    }
}
