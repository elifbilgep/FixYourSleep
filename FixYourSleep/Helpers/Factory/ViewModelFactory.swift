//
//  ViewModelFactory\.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 5.12.2024.
//

import Foundation

@MainActor
protocol ViewModelFactoryProtocol {
    func makeSignUpViewModel() -> SignUpViewModel
    func makeHomeViewModel() -> HomeViewModel
    func makeSignInViewModel() -> SignInViewModel
    func makeSplashViewModel() -> SplashViewModel
    func makeOnboardingViewModel() -> OnboardingViewModel
    func makeSleeepRotuineViewModel() -> SleepRoutineViewModel
}

class ViewModelFactory: ViewModelFactoryProtocol {
    let authManager: AuthManagerProtocol
    let userService: UserServiceProtocol
    let sleepService: SleepServiceProtocol
    let notificationManager: NotificationManager
    
    init(authManager: AuthManagerProtocol, userService: UserServiceProtocol, sleepService: SleepServiceProtocol, notificationManager: NotificationManager) {
        self.authManager = authManager
        self.userService = userService
        self.sleepService = sleepService
        self.notificationManager = notificationManager
    }
    
    func makeSignUpViewModel() -> SignUpViewModel {
        return SignUpViewModel(authManager: authManager, userService: userService)
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            authManager: authManager,
            userService: userService,
            sleepService: sleepService
        )
    }
    
    func makeSignInViewModel() -> SignInViewModel {
        return SignInViewModel(authManager: authManager)
    }
    
    func makeSplashViewModel() -> SplashViewModel {
        return SplashViewModel(userService: userService, authManager: authManager)
    }
    
    func makeOnboardingViewModel() -> OnboardingViewModel {
        return OnboardingViewModel(
            notificationManager: notificationManager,
            userService: userService,
            authManager: authManager
        )
    }
    
    func makeSleeepRotuineViewModel() -> SleepRoutineViewModel {
        return SleepRoutineViewModel()
    }
}
