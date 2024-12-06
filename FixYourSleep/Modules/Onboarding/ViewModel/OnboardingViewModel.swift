//
//  OnboardingViewModel.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 6.12.2024.
//

import Foundation

final class OnboardingViewModel: ObservableObject {
private let userService: UserServiceProtocol
@Published var isLoading = false
@Published var error: Error?

init(userService: UserServiceProtocol) {
    self.userService = userService
}

func fetchUserIfAvailable(with userId: String) async -> FYSUser? {
    let result = await userService.getUser(id: userId)
    
    switch result {
    case .success(let user):
        return user
    case .failure(let error):
        await MainActor.run {
            self.error = error
        }
        return nil
    }
}

@MainActor
func updateGoalSleepingTime(for user: FYSUser, newTime: String) async {
    isLoading = true
    error = nil  // Reset any previous errors
    
    let updatedUser = FYSUser(
        id: user.id,
        userName: user.userName,
        email: user.email,
        goalSleepingTime: newTime,
        notificationTime: user.notificationTime,
        isAlarmEnabled: user.isAlarmEnabled,
        isNotificationEnabled: user.isNotificationEnabled
    )
    
    let result = await userService.updateUser(updatedUser)
    
    isLoading = false
    
    switch result {
    case .success:
        // Update completed successfully
        break
    case .failure(let updateError):
        error = updateError
    }
}
}
