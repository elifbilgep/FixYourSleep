//
//  SignInViewModel.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 6.12.2024.
//

import Foundation
import AuthenticationServices

@MainActor
final class SignInViewModel: ObservableObject {
    private var authManager: AuthManagerProtocol
    @Published var alertMessage: String = ""
    @Published var isAlertPresented: Bool = false
    
    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
    }

    func signIn(with mail: String, password: String, completion: @escaping (Bool) -> Void) async throws {
        do {
            try await authManager.mailSignIn(mail: mail, password: password)
            completion(true)
        } catch let error {
            alertMessage = error.localizedDescription
            isAlertPresented = true
            completion(false)
        }
    }
    
    func handleAppleID(_ result: Result<ASAuthorization, Error>) async  {
        switch result {
        case .success(let auth):
            guard let appleIDCredentials = auth.credential as? ASAuthorizationAppleIDCredential else {
                print("AppleAuthorization failed: AppleID credential not available")
                return
            }
            
        case .failure(let error):
            print("AppleAuthorization failed: \(error)")
          
        }
    }
}
