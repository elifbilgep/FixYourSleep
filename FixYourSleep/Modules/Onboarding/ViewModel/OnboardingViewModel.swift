//
//  OnboardingViewModel.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 6.12.2024.
//

import Foundation

final class OnboardingViewModel: ObservableObject {
    //MARK: Properties
    let notificationManager: NotificationManager
    private let userService: UserServiceProtocol
    private let authManager: AuthManagerProtocol
    @Published var isLoading = false
    @Published var error: Error?
    
    //MARK: Init
    init(notificationManager: NotificationManager, userService: UserServiceProtocol, authManager: AuthManagerProtocol) {
        self.notificationManager = notificationManager
        self.userService = userService
        self.authManager = authManager
    }
    
    //MARK: Fetch User If Available
    func fetchUserIfAvailable(with userId: String) async -> FYSUser? {
        let result = await userService.getUser(id: userId)
        
        switch result {
        case .success(let user):
            return user
        case .failure(let error):
            print("Error fetching user: \(error)")
            return nil
        }
    }
    
    //MARK: Update Goal
    func updateGoalSleepingTime(id: String, bedTime: String, wakeTime: String) async {
        let _ = await userService.updateGoalSleepingTime(id: id, bedTime: bedTime, wakeTime: wakeTime)
    }
    
    
    //MARK: Update user in Firebase 
    private func updateUserInFirebase(_ user: FYSUser) async {
        print("🔄 Updating user in Firebase:", user.id)
        let result = await userService.updateUser(user)
        
        switch result {
        case .success(let updatedUser):
            print("✅ Successfully updated user with ID:", updatedUser.id)
        case .failure(let updateError):
            print("❌ Failed to update user:", updateError)
            error = updateError
        }
    }
    
    func requestNotificationPermission( onGranted: @escaping () -> Void) async {
        do {
            let granted = try await notificationManager.requestPermission()
            await MainActor.run {
                if granted {
                    onGranted()
                } else {
                   error = NotificationError.notificationsDenied
                }
            }
        } catch {
            self.error = error
        }
    }
}
