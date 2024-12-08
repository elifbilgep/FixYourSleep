//
//  SignUpViewModel.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 5.12.2024.
//

import Foundation
import SwiftUI
import AuthenticationServices
import GoogleSignIn
import FirebaseFirestore
import FirebaseAuth

@MainActor
class SignUpViewModel: ObservableObject {
    private let authManager: AuthManagerProtocol
    private let userService: UserServiceProtocol
    @Published var isLoading = false
    @Published var errorMessage: String?
    private var currentNonce: String?
    
    init(authManager: AuthManagerProtocol, userService: UserServiceProtocol) {
        self.authManager = authManager
        self.userService = userService
    }
    
    func signUp(username: String, email: String, password: String) async throws -> FYSUser {
        try await mailSignUp(mail: email, password: password)
        let currentUser = try await authManager.getCurrentUser()
        
        let newUser = FYSUser(
            id: currentUser.uid,
            userName: username,
            email: email,
            goalSleepingTime: nil,
            notificationTime: nil,
            isAlarmEnabled: nil,
            isNotificationEnabled: nil
        )
        
        try await createNewUserForMailSignUp(user: newUser)
        
        return newUser
    }
    
    func googleSignIn() {
        Task {
            do {
                isLoading = true
                let gIDGoogleUser = try await authManager.googleOauth()
                let currentUser = try await authManager.getCurrentUser() 
                if let authUser = gIDGoogleUser?.profile {
                    try await handleUserSignIn(userId: currentUser.uid, authUser: authUser)
                }
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
    
    private func handleUserSignIn(userId: String, authUser: GIDProfileData) async throws {
        let result = await userService.getUser(id: userId)
        
        switch result {
        case .success(_):
            let updatedUser = FYSUser(
                id: userId,
                userName: authUser.name,
                email: authUser.email,
                goalSleepingTime: nil,
                notificationTime: nil,
                isAlarmEnabled: nil,
                isNotificationEnabled: nil
            )
            _ = await userService.updateUser(updatedUser)
            
        case .failure(_):
            let newUser = FYSUser(
                id: userId,
                userName: authUser.name,
                email: authUser.email,
                goalSleepingTime: nil,
                notificationTime: nil,
                isAlarmEnabled: nil,
                isNotificationEnabled: nil
            )
            _ = await userService.createUser(newUser)
        }
    }
    @MainActor
    func mailSignUp(mail: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authManager.mailSignUp(mail: mail, password: password)
        } catch {
            print("‼️ Error occurred: \(error)")
            throw error
        }
    }
    
    func createNewUserForMailSignUp(user: FYSUser) async throws {
        let newUser = FYSUser(
            id: user.id,
            userName: user.userName,
            email: user.email,
            goalSleepingTime: nil,
            notificationTime: nil,
            isAlarmEnabled: nil,
            isNotificationEnabled: nil
        )
        
        let result = await userService.createUser(newUser)
        switch result {
        case .success:
            print("New user data uploaded to Firestore")
        case .failure(let error):
            throw error
        }
    }
    
    func handleAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = authManager.randomNonceString(length: 32)
        currentNonce = nonce
        request.nonce = authManager.sha256(nonce)
    }
    
    func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    do {
                        guard let nonce = currentNonce else {
                            fatalError("Invalid state: A login callback was received, but no login request was sent.")
                        }
                        
                        if let authResult = try await authManager.appleAuth(appleIDCredential, nonce: nonce) {
                            let userId = authResult.user.uid
                            let email = appleIDCredential.email ?? ""
                            let fullName = appleIDCredential.fullName
                            let userName = "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")".trimmingCharacters(in: .whitespaces)
                            
                            let newUser = FYSUser(
                                id: userId,
                                userName: userName,
                                email: email,
                                goalSleepingTime: nil,
                                notificationTime: nil,
                                isAlarmEnabled: nil,
                                isNotificationEnabled: nil
                            )
                            
                            let result = await userService.getUser(id: userId)
                            switch result {
                            case .success(_):
                                _ = await userService.updateUser(newUser)
                            case .failure(_):
                                _ = await userService.createUser(newUser)
                            }
                        }
                    } catch {
                        handleError(error)
                    }
                }
            }
        case .failure(let error):
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        if let authError = error as? AuthErrorCode {
            switch authError {
            case .accountExistsWithDifferentCredential:
                errorMessage = "An account already exists with a different sign-in method. Please use that method to sign in."
            case .credentialAlreadyInUse:
                errorMessage = "This Google account is already linked to a user. Please sign in with your existing account."
            default:
                errorMessage = "An error occurred during sign-in. Please try again."
            }
        } else {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        print("Error in sign in: \(error)")
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

}
