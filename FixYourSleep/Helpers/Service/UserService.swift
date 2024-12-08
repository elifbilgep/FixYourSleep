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
        do {
            // Get direct document reference instead of using query
            let documentRef = firebaseService.database.collection(Collections.users.rawValue).document(id)
            let document = try await documentRef.getDocument()
            
            guard let data = document.data() else {
                print("❌ No data found for user")
                return .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found"]))
            }
            
            print("📄 Raw document data:", data)
            
            // Create user manually from data
            let user = FYSUser(
                id: id,
                userName: data["userName"] as? String ?? "",
                email: data["email"] as? String ?? "",
                goalSleepingTime: data["goalSleepingTime"] as? String,
                notificationTime: data["notificationTime"] as? String,
                isAlarmEnabled: data["isAlarmEnabled"] as? Bool,
                isNotificationEnabled: data["isNotificationEnabled"] as? Bool,
                sleepData: data["sleepData"] as? [SleepData]
            )
            
            print("✅ Created user object:", user)
            print("Goal sleeping time:", user.goalSleepingTime ?? "nil")
            
            return .success(user)
        } catch {
            print("❌ Error fetching user:", error)
            return .failure(error)
        }
    }
    func updateUser(_ user: FYSUser) async -> Result<FYSUser, Error> {
        await firebaseService.put(user, to: Collections.users.rawValue)
    }
    
    func deleteUser(_ user: FYSUser) async -> Result<Void, Error> {
        await firebaseService.delete(user, in: Collections.users.rawValue)
    }
}
