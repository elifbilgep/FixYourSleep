//
//  UserService.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 5.12.2024.
//

import Foundation

protocol UserServiceProtocol {
    func createUser(_ user: FYSUser) async -> Result<FYSUser, Error>
    func getUser(id: String) async -> Result<FYSUser, Error>
    func updateUser(_ user: FYSUser) async -> Result<FYSUser, Error>
    func deleteUser(_ user: FYSUser) async -> Result<Void, Error>
}

class UserService: UserServiceProtocol {
    private let firebaseService: FirebaseServiceProtocol
    
    init(firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    func createUser(_ user: FYSUser) async -> Result<FYSUser, Error> {
        await firebaseService.put(user, to: Collections.users.rawValue)
    }
    
    func getUser(id: String) async -> Result<FYSUser, Error> {
        let query = firebaseService.database.collection(Collections.users.rawValue)
            .whereField("id", isEqualTo: id)
        return await firebaseService.getOne(of: FYSUser.self, with: query)
    }
    
    func updateUser(_ user: FYSUser) async -> Result<FYSUser, Error> {
        await firebaseService.put(user, to: Collections.users.rawValue)
    }
    
    func deleteUser(_ user: FYSUser) async -> Result<Void, Error> {
        await firebaseService.delete(user, in: Collections.users.rawValue)
    }
}
