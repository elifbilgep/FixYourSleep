//
//  SleepData.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 8.12.2024.
//

import Foundation


struct SleepData: FirebaseIdentifiable, Codable {
    var id: String
    let date: Date
    let sleepTime: Date
    let wakeTime: Date
    let isCompleted: Bool
    
    var totalSleepHours: Double {
        return wakeTime.timeIntervalSince(sleepTime) / 3600
    }
}
