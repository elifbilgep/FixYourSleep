//
//  FixYourSleepApp.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 3.12.2024.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@MainActor
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

@main
struct FixYourSleepApp: App {
    @StateObject private var router = RouterManager()
    private let notificationmanager: NotificationManager
    private let viewModelFactory: ViewModelFactoryProtocol
    @StateObject private var userStateManager = UserStateManager()
    init() {
        FirebaseApp.configure()
        let firestore = Firestore.firestore()
        let firebaseService = FirebaseService(database: firestore)
        let authManager = AuthManager()
        let userService = UserService(firebaseService: firebaseService)
        let sleepService = SleepService(firebaseService: firebaseService)
        self.notificationmanager = NotificationManager.shared
        viewModelFactory = ViewModelFactory(
            authManager: authManager,
            userService: userService,
            sleepService: sleepService,
            notificationManager: notificationmanager
        )
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navigationPath) {
                SplashView(viewModel: viewModelFactory.makeSplashViewModel())
                    .navigationDestination(for: RouterManager.Destination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .preferredColorScheme(.dark)
            .environmentObject(router)
            .environmentObject(userStateManager)
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: RouterManager.Destination) -> some View {
        switch destination {
        case .home:
            HomeView(viewModel: viewModelFactory.makeHomeViewModel())
        case .splash:
            SplashView(viewModel: viewModelFactory.makeSplashViewModel() )
        case .welcome:
            WelcomeView()
        case .signIn:
            SignInView(viewModel: viewModelFactory.makeSignInViewModel(), signUpViewModel: viewModelFactory.makeSignUpViewModel())
        case .signUp:
            SignUpView(viewModel: viewModelFactory.makeSignUpViewModel())
        case .onBoarding:
            OnboardingView(viewModel: viewModelFactory.makeOnboardingViewModel())
        case .sleep:
            SleepRoutineView(viewModel: viewModelFactory.makeSleeepRotuineViewModel())
        case .editRoutineView:
            EditGoalRoutineView(homeViewModel: viewModelFactory.makeHomeViewModel())
        }
    }
}
