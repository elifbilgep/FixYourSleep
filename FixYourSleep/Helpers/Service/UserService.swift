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
    func updateGoalSleepingTime(id: String, bedTime: String, wakeTime: String) async -> Result<Void, Error>
}

enum UserServiceError: Error {
    case userNotFound
    case invalidData
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .userNotFound:
            return "User not found."
        case .invalidData:
            return "Invalid user data."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

class UserService: UserServiceProtocol {
    private let firebaseService: FirebaseServiceProtocol
    
    init(firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    //MARK: Create User
    func createUser(_ user: FYSUser) async -> Result<FYSUser, Error> {
        await firebaseService.save(user, to: Collections.users.rawValue)
    }
    
    //MARK: Get User
    func getUser(id: String) async -> Result<FYSUser, Error> {
        let query = firebaseService.database
             .collection(Collections.users.rawValue)
             .whereField("id", isEqualTo: id) // Define the query
         
         let result: Result<FYSUser, Error> = await firebaseService.getOne(of: FYSUser.self, with: query)
         
         switch result {
         case .success(let user):
             return .success(user)
         case .failure(let error):
             if case FirebaseError.documentNotFound = error {
                 return .failure(UserServiceError.userNotFound)
             }
             return .failure(UserServiceError.unknown(error))
         }
    }
    
    //MARK: Update User
    func updateUser(_ user: FYSUser) async -> Result<FYSUser, Error> {
        await firebaseService.save(user, to: Collections.users.rawValue)
    }
    
    //MARK: Delete User
    func deleteUser(_ user: FYSUser) async -> Result<Void, Error> {
        await firebaseService.delete(user, in: Collections.users.rawValue)
    }
    
    //MARK: Update Goal Sleeping Time
    func updateGoalSleepingTime(id: String, bedTime: String, wakeTime: String) async -> Result<Void, Error> {
        let fields: [String: Any] = [
            "bedTime": bedTime,
            "wakeTime": wakeTime
        ]
        return await firebaseService.updateField(in: Collections.users.rawValue, documentID: id, fields: fields)
    }
}
