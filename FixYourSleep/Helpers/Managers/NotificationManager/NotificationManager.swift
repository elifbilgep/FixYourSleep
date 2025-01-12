//
//  NotificationManager.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 9.12.2024.
//

import Foundation
import UserNotifications
import SwiftUI

enum NotificationError: LocalizedError {
    case notificationsDenied
    case notificationsNotDetermined
    case failedToSchedule
    
    var errorDescription: String? {
        switch self {
        case .notificationsDenied:
            return "Notifications are disabled. Please enable them in Settings."
        case .notificationsNotDetermined:
            return "Notification permissions haven't been determined yet."
        case .failedToSchedule:
            return "Failed to schedule notification."
        }
    }
}

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationsEnabled = false
    
    private init() {
        Task {
            await checkNotificationStatus()
        }
    }
    
    func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            isNotificationsEnabled = settings.authorizationStatus == .authorized
        }
    }
    
    func requestPermission() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    Task { @MainActor in
                        self.isNotificationsEnabled = granted
                    }
                    continuation.resume(returning: granted)
                }
            }
        case .denied:
            throw NotificationError.notificationsDenied
        case .authorized:
            return true
        case .provisional, .ephemeral:
            return true
        @unknown default:
            return false
        }
    }
    
    func scheduleSleepReminder(at time: Date, title: String = "Time to Sleep!", body: String = "Put down your phone and get some rest.") async throws {
        // Ensure we have permission first
        guard try await requestPermission() else {
            throw NotificationError.notificationsDenied
        }
        
        // Remove any existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Create date components for daily trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        // Create trigger for daily notification
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "sleep_reminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            throw NotificationError.failedToSchedule
        }
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview Helper
extension NotificationManager {
    static var preview: NotificationManager {
        let manager = NotificationManager()
        manager.isNotificationsEnabled = true
        return manager
    }
}
