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
            Text("Goal: Sleeping at \(userStateManager.fysUser?.goalSleepingTime ?? "23:00")")
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
                            .foregroundColor(.white)
                        
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
            .padding()
            .frame(width: UIScreen.screenWidth)
        }
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
            
            
            CustomButton(title: "I understand") {
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
                    .padding(.top, 30)
                Text("Read a book while I play calming sounds")
                    .font(.albertSans(.regular, size: 18))
                    .frame(width: 350, height: 50)
                    .multilineTextAlignment(.center)
            }
        
            // Sound options
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(["Rain", "Ocean", "White Noise"], id: \.self) { sound in
                        VStack {
                            Circle()
                                .fill(Color.customAccent.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Image(systemName: viewModel.selectedSound == sound ? "pause.circle.fill" : "play.circle.fill")
                                        .foregroundColor(.customAccent)
                                        .font(.system(size: 24))
                                }
                            Text(sound)
                                .font(.albertSans(.regular, size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(width: geometry.size.width / 3) // This ensures equal spacing
                        .onTapGesture {
                            viewModel.playSound(sound)
                        }
                    }
                }
            }
            .frame(height: 60) // Adjust this height as needed
        
            
            // Timer Text
            Text(viewModel.formatTime())
                .font(.system(size: 64, weight: .bold))
                .padding(.vertical, 20)
                
            // Button
            if viewModel.timeRemaining == 0 {
                CustomButton(title: "Continue") {
                    withAnimation {
                        currentStep += 1
                        viewModel.completeStepAndAddNext(1)
                    }
                    isSheetPresented = false
                }
            } else if !viewModel.isTimerRunning {
                CustomButton(title: "Start timer") {
                    viewModel.startTimer()
                }
            } else {
                Text("Please wait until the timer ends")
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 350)
        .interactiveDismissDisabled(viewModel.isTimerRunning) // Prevent dismissal while timer is running
        .onDisappear {
            if !viewModel.isTimerRunning {
                viewModel.timeRemaining = 600 // Reset timer if sheet is dismissed without starting
            }
        }
    }
    
    //MARK: Put Phone Away View
    @ViewBuilder
    private var putYourPhoneAway: some View {
       VStack(spacing: 24) {
           // Header
           VStack(spacing: 16) {
               Text("Put the phone far away")
                   .font(.albertSans(.semibold, size: 28))
               Image("phoneOnTable")
                   .resizable()
                   .scaledToFit()
                   .cornerRadius(15)
                   .padding(.vertical)
               Text("After 3 minutes, I'll start monitoring your phone's movement. Any phone activity will indicate you're not sleeping.")
                   .font(.albertSans(.regular, size: 18))
                   .multilineTextAlignment(.center)
                   .foregroundColor(.gray)
           }
           .padding(.vertical)
        
           CustomButton(title: "I understand") {
               withAnimation {
                   currentStep += 1
                   viewModel.completeStepAndAddNext(2)
               }
               isSheetPresented = false
           }
           .padding(.bottom, 20)
       }
       .padding(.horizontal)
       .frame(width: 350)
    }

}

struct Step: Identifiable {
    var id: String = UUID().uuidString
    var stepTitle: String
    var isCompleted: Bool
}


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

#Preview(body: {
    SleepRoutineView(viewModel: SleepRoutineViewModel(isPreview: true))
        .environmentObject(UserStateManager())
        .preferredColorScheme(.dark)
})
