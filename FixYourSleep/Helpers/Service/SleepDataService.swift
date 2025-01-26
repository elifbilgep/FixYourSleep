//
//  SleepDataService.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 12.01.2025.
//

import Foundation

protocol SleepServiceProtocol {
    func saveSleepLog(userId: String, sleepLog: SleepData) async -> Result<Void, Error>
    func fetchSleepLogs(userId: String) async -> Result<[SleepData], Error>
}

class SleepService: SleepServiceProtocol {
    
    //MARK: Properties
    private let firebaseService: FirebaseServiceProtocol
    
    init(firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    //MARK: Save Sleep Log
    func saveSleepLog(userId: String, sleepLog: SleepData) async -> Result<Void, Error> {
        let collectionPath = "Users/\(userId)/sleepLogs"
        return await firebaseService.save(sleepLog, to: collectionPath).map { _ in () }
    }
    
    //MARK: Fetch Sleep Logs
    func fetchSleepLogs(userId: String) async -> Result<[SleepData], Error> {
        let collectionPath = "Users/\(userId)/sleepLogs"
        let query = firebaseService.database.collection(collectionPath)
        return await firebaseService.getMany(of: SleepData.self, with: query)
    }
}
