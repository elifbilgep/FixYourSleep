//
//  HomeViewModel.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 6.12.2024.
//

import Foundation

final class HomeViewModel: ObservableObject {
     let authManager: AuthManagerProtocol
    
    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
    }
    
    func signOut() async {
        do {
            try await authManager.signOut()
        } catch {
            print("Error while logging out: \(error)")
        }
    }
}
