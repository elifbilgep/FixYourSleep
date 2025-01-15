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
    //MARK: Properties
    private let authManager: AuthManagerProtocol
    private let userService: UserServiceProtocol
    @Published var isLoading = false
    @Published var errorMessage: String?
    private var currentNonce: String?
    
    //MARK: Init
    init(authManager: AuthManagerProtocol, userService: UserServiceProtocol) {
        self.authManager = authManager
        self.userService = userService
    }
    
    //MARK: Sign Up
    func signUp(username: String, mail: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authManager.mailSignUp(mail: mail, password: password)
            isLoading = false
        } catch {
            isLoading = false
            print("‼️ Error occurred: \(error)")
            throw error
        }
    }
    
    //MARK: Google Sign In
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
    
    //MARK: Handle User Sign In from Google Sign in
    private func handleUserSignIn(userId: String, authUser: GIDProfileData) async throws {
        let result = await userService.getUser(id: userId)
        
        switch result {
        case .success(_):
            let updatedUser = FYSUser(
                id: userId,
                userName: authUser.name,
                email: authUser.email,
                bedTime: nil,
                wakeTime: nil,
                notificationTime: nil,
                isAlarmEnabled: nil,
                isNotificationEnabled: nil,
                sleepData: nil
            )
            _ = await userService.updateUser(updatedUser)
            
        case .failure(_):
            let newUser = FYSUser(
                id: userId,
                userName: authUser.name,
                email: authUser.email,
                bedTime: nil,
                wakeTime: nil,
                notificationTime: nil,
                isAlarmEnabled: nil,
                isNotificationEnabled: nil,
                sleepData: nil
            )
            _ = await userService.createUser(newUser)
        }
    }
    
    //MARK: Handle Apple sign in request
    func handleAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = authManager.randomNonceString(length: 32)
        currentNonce = nonce
        request.nonce = authManager.sha256(nonce)
    }
    
    //MARK: Handle apple sing in completion
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
                                bedTime: nil,
                                wakeTime: nil,
                                notificationTime: nil,
                                isAlarmEnabled: nil,
                                isNotificationEnabled: nil,
                                sleepData: nil
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
    
    //MARK: Handle Error
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
    
    //MARK: Fetch User if Available from firestore
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
