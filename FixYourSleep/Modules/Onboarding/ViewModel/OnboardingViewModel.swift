//
//  OnboardingViewModel.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 6.12.2024.
//

import Foundation
final class OnboardingViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let authManager: AuthManagerProtocol
    @Published var isLoading = false
    @Published var error: Error?
    
    init(userService: UserServiceProtocol, authManager: AuthManagerProtocol) {
        self.userService = userService
        self.authManager = authManager
    }
    
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
    
    @MainActor
    func updateGoalSleepingTime(for user: FYSUser, newTime: String) async {
        isLoading = true
        error = nil
        
        do {
            // Get current authenticated user
            let currentUser = try await authManager.getCurrentUser()
            print("Current auth user ID:", currentUser.uid)
            print("Attempting to update user ID:", user.id)
            
            // Check if IDs match
            if currentUser.uid != user.id {
                print("⚠️ User ID mismatch. Using current auth ID")
                // Get the correct user data first
                let result = await userService.getUser(id: currentUser.uid)
                switch result {
                case .success(let correctUser):
                    let updatedUser = FYSUser(
                        id: correctUser.id,
                        userName: correctUser.userName,
                        email: correctUser.email,
                        goalSleepingTime: newTime,
                        notificationTime: correctUser.notificationTime,
                        isAlarmEnabled: correctUser.isAlarmEnabled,
                        isNotificationEnabled: correctUser.isNotificationEnabled
                    )
                    await updateUserInFirebase(updatedUser)
                case .failure(let error):
                    print("❌ Error fetching correct user:", error)
                    self.error = error
                }
            } else {
                // IDs match, proceed with update
                let updatedUser = FYSUser(
                    id: user.id,
                    userName: user.userName,
                    email: user.email,
                    goalSleepingTime: newTime,
                    notificationTime: user.notificationTime,
                    isAlarmEnabled: user.isAlarmEnabled,
                    isNotificationEnabled: user.isNotificationEnabled
                )
                await updateUserInFirebase(updatedUser)
            }
        } catch {
            print("❌ Error getting current user:", error)
            self.error = error
        }
        
        isLoading = false
    }
    
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
}
