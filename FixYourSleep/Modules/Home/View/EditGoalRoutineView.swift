//
//  EditGoalRoutine.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 14.12.2024.
//

import SwiftUI

struct EditGoalRoutineView: View {
    @State private var showBedTimePicker = false
    @State private var showWakeTimePicker = false
    @State var selectedBedTime: Date
    @State var selectedWakeTime: Date
    @StateObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var userSateManager: UserStateManager
    @EnvironmentObject private var router: RouterManager
    @AppStorage(AppStorageKeys.bedTimeGoal) private var bedTimeGoal = "00:00"
    @AppStorage(AppStorageKeys.wakeTimeGoal) private var wakeTimeGoal = "00:00"
    
    init(homeViewModel: HomeViewModel) {
        let bedTime = DateFormatter.hhmm.date(from: UserDefaults.standard.string(forKey: AppStorageKeys.bedTimeGoal) ?? "00:00") ?? Date()
        let wakeTime = DateFormatter.hhmm.date(from: UserDefaults.standard.string(forKey: AppStorageKeys.wakeTimeGoal) ?? "00:00") ?? Date()
        _homeViewModel = StateObject(wrappedValue: homeViewModel)
        _selectedBedTime = State(initialValue: bedTime)
        _selectedWakeTime = State(initialValue: wakeTime)
    }
    
    var body: some View {
        ZStack {
            pickerView
            if showBedTimePicker {
                CustomTimePickerView(
                    isPresented: $showBedTimePicker,
                    selectedDate: $selectedBedTime
                )
            }
            if showWakeTimePicker {
                CustomTimePickerView(
                    isPresented: $showWakeTimePicker,
                    selectedDate: $selectedWakeTime
                )
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    private var pickerView: some View {
        VStack {
            CustomBackButton()
                .padding(.vertical)
            VStack(alignment: .leading, spacing: 6) {
                Text("Edit Your Sleep Routine")
                    .font(.albertSans(.semibold, size: 40))
                Text("Adjust your bedtime and wake-up time to improve your rest and well-being.")
                    .font(.albertSans(.regular, size: 20))
            }
            .padding(.leading, 20)
            .padding(.bottom, 40)
            .frame(width: UIScreen.screenWidth, alignment: .leading)
            
            VStack(spacing: 20) {
                VStack {
                    Text("Bedtime")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.gray)
                    Text(selectedBedTime.dateToHHMM())
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showBedTimePicker = true
                            }
                        }
                }
                
                VStack {
                    Text("Wake-up Time")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.gray)
                    Text(selectedWakeTime.dateToHHMM())
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showWakeTimePicker = true
                            }
                        }
                }
            }
            
            Spacer()
            
            CustomButton(title: "Save") {
                guard let user = userSateManager.fysUser else { return }
                bedTimeGoal = selectedBedTime.dateToHHMM()
                wakeTimeGoal = selectedWakeTime.dateToHHMM()
                Task {
                    await homeViewModel.updateGoalSleepingTime(
                        id: user.id,
                        bedTime: bedTimeGoal,
                        wakeTime: wakeTimeGoal
                    )
                }
                router.navigateBack()
            }
            
            Spacer()
        }
    }
}
