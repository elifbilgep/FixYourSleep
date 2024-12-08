//
//  AppManager.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 5.12.2024.
//

import Foundation
import FirebaseAuth

@MainActor
class UserStateManager: ObservableObject {
    @Published var user: User?
    @Published var fysUser: FYSUser?
    var authState: AuthState = .signedOut
    private var authStateHandler: AuthStateDidChangeListenerHandle!
    
    init() {
        configureAuthStateChanges()
    }
    
    func configureAuthStateChanges() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.updateStatus(user: user)
            }
        }
    }
    
    private func updateStatus(user: User?) {
        self.user = user
        let isAuthenticatedUser = user != nil
        let isAnonymous = user?.isAnonymous ?? false
        
        if isAuthenticatedUser {
            self.authState = isAnonymous ? .authenticated : .signedIn
        } else {
            self.authState = .signedOut
            self.fysUser = nil
            self.user = nil
        }
        print("‼️ User state changed: \(authState)")
    }
}
