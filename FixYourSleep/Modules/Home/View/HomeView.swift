//
//  HomeView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 3.12.2024.
//

import SwiftUI
import WidgetKit

struct HomeView: View {
    //MARK: Properties
    @StateObject private var viewModel: HomeViewModel
    
    @EnvironmentObject private var userSateManager: UserStateManager
    @EnvironmentObject private var router: RouterManager
    
    @State private var selectedDate: Date = Date()
    @State private var showNotSleepTimeAlert: Bool = false
    
    private var user: FYSUser? { userSateManager.fysUser }
    
    @AppStorage(AppStorageKeys.isSleepingRightNow) private var isSleepingRightNow: Bool = false
    @AppStorage(AppStorageKeys.bedTimeGoal) private var bedTimeGoal = "00:00"
    @AppStorage(AppStorageKeys.wakeTimeGoal) private var wakeTimeGoal = "00:00"
    @AppStorage(AppStorageKeys.username) private var username = ""
    
    @State private var hideTimer = false
    @State private var showCanceledView = false
    
    //MARK: Init
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: Sleep Time Text
    private var sleepTimeText: String {
        guard let user, let goalTime = user.bedTime else {
            return "Not set"
        }
        UserDefaults(suiteName: "group.com.elifbilgeparlak.fixyoursleep")?
            .set(goalTime, forKey: "sleepGoal")
        WidgetCenter.shared.reloadAllTimelines()
        return goalTime
    }
    
    //MARK: UserLogs
    private var userLogs: [SleepData] {
        user?.sleepData ?? []
    }
    
    var body: some View {
        ZStack {
            Color.blackBg
                .frame(height: UIScreen.screenHeight)
            VStack {
                appBarView
                titleView
                calendarView
                startSleepingView
                challengeView
                Spacer()
            }
            if isSleepingRightNow {
                isSleepingView
            }
            
            if showCanceledView {
                afterSleepCanceledView
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .onChange(of: isSleepingRightNow) { oldValue, newValue in
            if oldValue == true && newValue == false {
                showCanceledView = true
                viewModel.stopMotionDetection()
            }
        }
        .onChange(of: userSateManager.authState, { oldValue, newValue in
            if newValue == .signedOut {
                router.navigateTo(to: .welcome)
            }
        })
        
    }
    
    //MARK: Appbar View
    @ViewBuilder
    private var appBarView: some View {
        HStack {
            Image("sleepyDoodle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .onTapGesture {
                    Task {
                        await viewModel.signOut()
                    }
                    username = ""
                }
            Spacer()
            Image(systemName: "bell.fill")
                .font(.system(size: 22))
        }
        .padding(.horizontal, 20)
        .padding(.top, 80)
    }
    
    //MARK: Title View
    @ViewBuilder
    private var titleView: some View {
        VStack(alignment: .leading) {
            Text("Time to fix your sleep")
                .font(.albertSans(.bold, size: 32))
            Text("Live your day the fullest")
                .font(.albertSans(.regular, size: 20))
        }
        .padding()
        .frame(width: UIScreen.screenWidth, alignment: .leading)
        
    }
    
    //MARK: Calendar View
    @ViewBuilder
    private var calendarView: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculate dates centered around today
        let dates = (-3...3).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
        
        HStack(spacing: 8) {
            ForEach(dates, id: \.timeIntervalSince1970) { date in
                let isPast = date < today
                let isLogAvailable = isPast ? viewModel.sleepLogsByDate[calendar.startOfDay(for: date)] ?? false : nil
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(isDateSelected(date) ? .customAccentDark : .darkGray)
                    .frame(width: 45, height: 90, alignment: .center)
                    .overlay {
                        VStack(spacing: 6) {
                            Text(calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1])
                                .font(.albertSans(.bold, size: 14))
                            
                            Text("\(calendar.component(.day, from: date))")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(isDateSelected(date) ? .white : .white.opacity(0.8))
                            
                            if isPast {
                                Circle()
                                    .fill(.gray)
                                    .frame(width: 18, height: 18)
                                    .overlay {
                                        Image(systemName: isLogAvailable == true ? "checkmark" : "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 18, height: 18)
                            }
                        }
                    }
            }
        }
        .onAppear {
            if let userId = user?.id {
                Task {
                    await viewModel.fetchLogsForDates(dates: dates, userId: userId)
                }
            }
        }
    }
    
    //MARK: Challenge View
    @ViewBuilder
    private var challengeView: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text("Weekly Sleep Challenge")
                    .font(.albertSans(.semibold, size: 24))
                Spacer()
                Text("Edit")
                    .underline()
                    .font(.albertSans(.semibold, size: 18))
                    .onTapGesture {
                        router.navigateTo(to: .editRoutineView)
                    }
            }
            HStack {
                ChallengeView(challengeType: .sleep, goalTime: bedTimeGoal)
                ChallengeView(challengeType: .wakeUp, goalTime: wakeTimeGoal)
            }
            
        }
        .padding()
    }
    
    //MARK: Start Sleeping
    @ViewBuilder
    private var startSleepingView: some View {
        VStack(alignment: .leading) {
            Text("Start sleeping")
                .font(.albertSans(.semibold, size: 24))
            Image("space2") // Add space.jpg to your assets
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay {
                    HStack {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Start your sleep routine")
                                .font(.albertSans(.semibold, size: 16))
                            Text("Complete the steps to prepare for bed so the app can track your sleep accurately and help you improve your sleep habits.")
                                .font(.albertSans(.regular, size: 14))
                        }
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 22))
                    }
                    .padding()
                }
        }
        .padding()
        .onTapGesture {
            router.navigateTo(to: .sleep)
            if isNearSleepTime() {
                router.navigateTo(to: .sleep)
            } else {
                //showNotSleepTimeAlert = true
            }
        }
        .alert("Not Sleeping Time!", isPresented: $showNotSleepTimeAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("It's not your bedtime yet! Your scheduled sleep time is \(sleepTimeText). Come back later!")
        }
    }
    
    //MARK: isSleeping view
    @ViewBuilder
    private var isSleepingView: some View {
        Color.black.opacity(0.7)
            .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.darkGray)
            .frame(width: 350, height: hideTimer ? 500 : 650)
            .overlay {
                VStack(spacing: 24) {
                    Text("You are sleeping,\nright?")
                        .font(.albertSans(.bold, size: 32))
                        .padding(.bottom)
                    Image("isSleeping")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                    hideTimer ? nil : Text(viewModel.formatCountdownTime())
                        .font(.albertSans(.semibold, size: 64))
                    Text("You can't pick up your phone after this time ends, I will know!")
                        .font(.albertSans(.semibold, size: 14))
                        .padding(.bottom, 6)
                    
                    Text("Cancel the sleep")
                        .underline()
                        .foregroundStyle(.red)
                        .onTapGesture {
                            withAnimation {
                                isSleepingRightNow = false
                                viewModel.stopSleepCountdown()
                            }
                            
                        }
                    
                }
                .padding()
                .multilineTextAlignment(.center)
            }
            .onAppear {
                viewModel.startSleepCountdown { result in
                    if result {
                        hideTimer = true
                    }
                }
            }
    }
    
    //MARK: afterSleepCanceledView
    @ViewBuilder
    private var afterSleepCanceledView: some View {
        Color.black.opacity(0.7)
            .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.darkGray)
            .frame(width: 350, height: hideTimer ? 300 : 500)
            .overlay {
                VStack(spacing: 24) {
                    Text("Sleep interrupted!")
                        .font(.albertSans(.bold, size: 32))
                        .padding(.bottom)
                    
                    Text("You picked up your phone so your sleep is inturrepted.")
                        .font(.albertSans(.semibold, size: 14))
                        .padding(.bottom, 6)
                    
                    CustomButton(title: "I put away my phone, start sleeping.", action: {
                        withAnimation {
                            showCanceledView = false
                            isSleepingRightNow = true
                        }
                        hideTimer = false
                    }, isSecondary: false, size: .small)
                    Text("Cancel Sleep")
                        .underline()
                        .foregroundStyle(.red)
                        .onTapGesture {
                            withAnimation {
                                showCanceledView = false
                            }
                        }
                }
                .padding()
                .multilineTextAlignment(.center)
            }
    }
    
    
    
    //MARK: Is Date Selected
    private func isDateSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .day)
    }
    
    //MARK: get sleep datta status
    private func getSleepDataStatus(for date: Date) -> Bool? {
        // Only return status for past dates
        guard date <= Date() else { return nil }
        
        return userLogs.first { log in
            Calendar.current.isDate(log.date, inSameDayAs: date)
        }?.isCompleted
    }
    
    //MARK: isNearSleepTime
    private func isNearSleepTime() -> Bool {
        guard let user = user,
              let goalTimeString = user.bedTime else {
            return false
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let goalTime = dateFormatter.date(from: goalTimeString) else {
            return false
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Get current hour and minute
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        // Get goal hour and minute
        let goalHour = calendar.component(.hour, from: goalTime)
        let goalMinute = calendar.component(.minute, from: goalTime)
        
        // Convert both times to minutes since midnight for easier comparison
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        let goalTimeInMinutes = goalHour * 60 + goalMinute
        
        // Allow starting sleep routine within 30 minutes before goal time
        let timeBuffer = 30
        let difference = abs(currentTimeInMinutes - goalTimeInMinutes)
        
        return difference <= timeBuffer
    }
    
}

struct LinearProgressView: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.customAccent)
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(.white)
                    .frame(width: geometry.size.width * progress, height: 8)
            }
        }
        .frame(height: 8)
    }
}

