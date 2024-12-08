//
//  HomeView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 3.12.2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var userSateManager: UserStateManager
    @EnvironmentObject private var router: RouterManager
    @EnvironmentObject private var userStateManager: UserStateManager
    @State private var selectedDate: Date = Date()
    
    private var user: FYSUser? { userSateManager.fysUser }
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var sleepTimeText: String {
        guard let user, let goalTime = user.goalSleepingTime else {
            return "Not set"
        }
        return goalTime
    }
    
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
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
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
        let today = Date()
        let week = calendar.dateInterval(of: .weekOfMonth, for: today)!
        let days = calendar.generateDates(
            inside: week,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
        
        HStack(spacing: 8) {
            ForEach(days, id: \.timeIntervalSince1970) { date in
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
                            
                            Circle()
                                .fill(isDateSelected(date) ? Color.customAccent : .customGray)
                                .frame(width: 18, height: 18)
                                .overlay {
                                    if Calendar.current.isDateInToday(date) {
                                        // Empty circle for today
                                    } else if let isCompleted = getSleepDataStatus(for: date) {
                                        Image(systemName: isCompleted ? "checkmark" : "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(isCompleted ? .white : .red)
                                    } else {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                        }
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
                    .font(.albertSans(.semibold, size: 16))
            }
            
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(hex: "1C1B3A"), location: 0.0),
                            Gradient.Stop(color: Color(hex: "010103"), location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 160)
                .overlay {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .font(.system(size: 16))
                            Text("Sleep at \(sleepTimeText)")
                                .font(.albertSans(.semibold, size: 20))
                            Spacer()
                        }
                        Text("Get enough sleep to recharge your body")
                            .font(.albertSans(.semibold, size: 18))
                        LinearProgressView(progress: 0)
                        Text("Sleep at 11 pm 5 more days to complete monthly goal")
                            .font(.albertSans(.bold, size: 12))
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal)
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
        }
    }
    
    //MARK: Is Date Selected
    private func isDateSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .day)
    }
    
    //MARK: get sleep datta status
    private func getSleepDataStatus(for date: Date) -> Bool? {
        return userLogs.first { log in
            Calendar.current.isDate(log.date, inSameDayAs: date)
        }?.isCompleted
    }
}
#Preview {
    HomeView(viewModel: HomeViewModel(authManager: AuthManager()))
        .preferredColorScheme(.dark)
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

