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
    @Published var error: String?
    
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
    func updateGoalSleepingTime(id: String, bedTime: String, wakeTime: String, completion: @escaping (Bool) -> Void) async {
        let result = await userService.updateGoalSleepingTime(id: id, bedTime: bedTime, wakeTime: wakeTime)
        switch result {
        case .success(_):
            completion(true)
        case .failure(let failure):
            self.error = failure.localizedDescription
            completion(false)
        }
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
            error = updateError.localizedDescription
        }
    }
    
    //MARK: Request Notification Permission
    func requestNotificationPermission(onGranted: @escaping () -> Void) async {
        do {
            let granted = try await notificationManager.requestPermission()
            await MainActor.run {
                if granted {
                    onGranted()
                } else {
                    error = NotificationError.notificationsDenied.localizedDescription
                }
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    //MARK: Create new user for mail signup
    func createNewUserForMailSignUp(user: FYSUser) async throws {
        let newUser = FYSUser(
            id: user.id,
            userName: user.userName,
            email: user.email,
            bedTime: user.bedTime,
            wakeTime: user.wakeTime,
            notificationTime: nil,
            isAlarmEnabled: false,
            isNotificationEnabled: false,
            sleepData: nil
        )
        
        let result = await userService.createUser(newUser)
        switch result {
        case .success:
            print("New user data uploaded to Firestore")
        case .failure(let error):
            throw error
        }
    }
}
