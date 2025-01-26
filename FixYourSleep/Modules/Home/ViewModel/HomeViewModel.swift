//
//  HomeViewModel.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 6.12.2024.
//

import Foundation
import CoreMotion
import UserNotifications
import UIKit

protocol HomeViewModelProtocol {
    func startSleepCountdown(completion: @escaping (Bool) -> Void)
    func stopSleepCountdown()
    func formatCountdownTime() -> String
    func signOut() async
    func updateGoalSleepingTime(id: String, bedTime: String, wakeTime: String) async
    func stopMotionDetection()
}

final class HomeViewModel: ObservableObject, HomeViewModelProtocol {
    //MARK: Properties
    let authManager: AuthManagerProtocol
    let userService: UserServiceProtocol
    let sleepService: SleepServiceProtocol
    @Published var sleepCountdownSeconds: Int = 10
    @Published var sleepLogsByDate: [Date: Bool] = [:]
    private var timer: Timer?
    private let motionManager = CMMotionManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    //MARK: Init
    init(authManager: AuthManagerProtocol, userService: UserServiceProtocol, sleepService: SleepServiceProtocol) {
        self.authManager = authManager
        self.userService = userService
        self.sleepService = sleepService
    }
    
    //MARK: Start Sleep Countdown
    func startSleepCountdown(completion: @escaping (Bool) -> Void) {
        sleepCountdownSeconds = 10 // Changed from 180 to 10 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.sleepCountdownSeconds > 0 {
                self.sleepCountdownSeconds -= 1
            } else {
                self.stopSleepCountdown()
                completion(true)
                self.startMotionDetection()
            }
        }
    }
    
    //MARK: Stop Sleep Countdown
    func stopSleepCountdown() {
        timer?.invalidate()
        timer = nil
    }
    
    //MARK: Format Countdown Time
    func formatCountdownTime() -> String {
        let minutes = sleepCountdownSeconds / 60
        let seconds = sleepCountdownSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    //MARK: Sign Out
    func signOut() async {
        do {
            try await authManager.signOut()
        } catch {
            print("Error while logging out: \(error)")
        }
    }
    
    //MARK: Update Goal
    func updateGoalSleepingTime(id: String, bedTime: String, wakeTime: String) async {
        let _ = await userService.updateGoalSleepingTime(id: id, bedTime: bedTime, wakeTime: wakeTime)
    }
    
    //MARK: Private Methods
    
    
    //MARK: Start Motion Detection
    private func startMotionDetection() {
        guard motionManager.isAccelerometerAvailable else {
            print("⚠️ Accelerometer is not available")
            return
        }
        
        print("🎯 Starting motion detection...")
        motionManager.accelerometerUpdateInterval = 1.0
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data else {
                print("❌ No motion data available")
                return
            }
            
            let pickupThreshold: Double = 0.6  
            print("📱 Motion detected - X: \(data.acceleration.x), Y: \(data.acceleration.y), Z: \(data.acceleration.z)")
            
            if abs(data.acceleration.y) > pickupThreshold {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("🚨 Phone pickup detected! Above threshold: \(pickupThreshold)")
                    self?.handlePhonePickup()
                }
            }
        }
    }
    
    //MARK: Stop Motion Detection
    func stopMotionDetection() {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func handlePhonePickup() {
        guard let _ = UserDefaults.standard.string(forKey: AppStorageKeys.username),
              let wakeTimeString = UserDefaults.standard.string(forKey: AppStorageKeys.wakeTimeGoal) else {
            stopMotionDetection()
            print("No user found")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let wakeTime = dateFormatter.date(from: wakeTimeString) else {
            stopMotionDetection()
            return
        }
        
        let now = Date()
        
        if now >= wakeTime {
            logSleepSession(isCompleted: true)
        } else {
            interruptSleepSession()
        }
        stopMotionDetection()
    }
    
    // MARK: Log Sleep Session
    private func logSleepSession(isCompleted: Bool) {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            print("No user found")
            return
        }
        
        let sleepData = SleepData(id: UUID().uuidString, date: Date(), isCompleted: isCompleted)
        Task {
            let result = await sleepService.saveSleepLog(userId: userId, sleepLog: sleepData)
            switch result {
            case .success:
                print("✅ Sleep session logged successfully.")
            case .failure(let error):
                print("❌ Failed to log sleep session: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Interrupt Sleep Session
    private func interruptSleepSession() {
        // Existing behavior for interrupted sleep
        let content = UNMutableNotificationContent()
        content.title = "Sleep Interrupted!"
        content.body = "You picked up your phone! Sleep session cancelled."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        if UIApplication.shared.applicationState == .active {
            DispatchQueue.main.async {
                UserDefaults.standard.set(false, forKey: AppStorageKeys.isSleepingRightNow)
                NotificationCenter.default.post(
                    name: Notification.Name("ShowSleepInterruptedAlert"),
                    object: nil
                )
            }
        } else {
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error sending notification: \(error)")
                }
            }
            DispatchQueue.main.async {
                UserDefaults.standard.set(false, forKey: AppStorageKeys.isSleepingRightNow)
            }
        }
    }
    
    //MARK: Fetch Sleep Logs
    func fetchLogsForDates(dates: [Date], userId: String) async {
        let calendar = Calendar.current
        let result = await sleepService.fetchSleepLogs(userId: userId)
        
        switch result {
        case .success(let logs):
            let logsByDate = logs.reduce(into: [Date: Bool]()) { result, log in
                let logDate = calendar.startOfDay(for: log.date)
                result[logDate] = log.isCompleted
            }
            
            DispatchQueue.main.async {
                self.sleepLogsByDate = dates.reduce(into: [Date: Bool]()) { result, date in
                    let startOfDay = calendar.startOfDay(for: date)
                    result[startOfDay] = logsByDate[startOfDay, default: false]
                }
            }
        case .failure(let error):
            print("❌ Failed to fetch logs: \(error.localizedDescription)")
        }
    }
    
    
    //MARK: Deinit
    deinit {
        timer?.invalidate()
        stopMotionDetection()
    }
}
