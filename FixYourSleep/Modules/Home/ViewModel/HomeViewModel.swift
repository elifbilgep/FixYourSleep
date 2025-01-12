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
    @Published var sleepCountdownSeconds: Int = 10 // 3 minutes in seconds
    private var timer: Timer?
    private let motionManager = CMMotionManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    //MARK: Init
    init(authManager: AuthManagerProtocol, userService: UserServiceProtocol) {
        self.authManager = authManager
        self.userService = userService
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
            
            let pickupThreshold: Double = 0.6  // Increased threshold
            
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
    
    //MARK: Handle Phone Pickup
    private func handlePhonePickup() {
        // Stop monitoring once we detect pickup
        stopMotionDetection()
        
        // Send local notification
        let content = UNMutableNotificationContent()
        content.title = "Sleep Interrupted!"
        content.body = "You picked up your phone! Sleep session cancelled."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        // Check if app is in foreground
        if UIApplication.shared.applicationState == .active {
            // Show in-app alert
            DispatchQueue.main.async {
                // Update UI state
                UserDefaults.standard.set(false, forKey: AppStorageKeys.isSleepingRightNow)
                
                // You can handle this alert in your SwiftUI view
                NotificationCenter.default.post(
                    name: Notification.Name("ShowSleepInterruptedAlert"),
                    object: nil
                )
            }
        } else {
            // Send notification if app is in background
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error sending notification: \(error)")
                }
            }
            
            // Update UI state
            DispatchQueue.main.async {
                UserDefaults.standard.set(false, forKey: AppStorageKeys.isSleepingRightNow)
            }
        }
    }
    
    
    
    //MARK: Deinit
    deinit {
        timer?.invalidate()
        stopMotionDetection()
    }
}
