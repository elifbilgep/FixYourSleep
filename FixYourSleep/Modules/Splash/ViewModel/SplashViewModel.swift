//
//  SplashViewModel.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 6.12.2024.
//

import Foundation
import SwiftUI

final class SplashViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let authmanager: AuthManagerProtocol
        
        init(userService: UserServiceProtocol, authManager: AuthManagerProtocol) {
            self.userService = userService
            self.authmanager = authManager
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
    
    func signOut () async throws {
        try? await authmanager.signOut()
        
        
    }
}
