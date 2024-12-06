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
}

class ViewModelFactory: ViewModelFactoryProtocol {
    let authManager: AuthManagerProtocol
    let userService: UserServiceProtocol
    
    init(authManager: AuthManagerProtocol, userService: UserServiceProtocol) {
        self.authManager = authManager
        self.userService = userService
    }
    
    func makeSignUpViewModel() -> SignUpViewModel {
        return SignUpViewModel(authManager: authManager, userService: userService)
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(authManager: authManager)
    }
    
    func makeSignInViewModel() -> SignInViewModel {
        return SignInViewModel(authManager: authManager)
    }
    
    func makeSplashViewModel() -> SplashViewModel {
        return SplashViewModel(userService: userService, authManager: authManager)
    }
    
    func makeOnboardingViewModel() -> OnboardingViewModel {
        return OnboardingViewModel(userService: userService)
    }
}
