//
//  FYSUser.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 5.12.2024.
//

import Foundation

struct FYSUser: FirebaseIdentifiable, Codable {
    var id: String
    let userName: String
    let email: String
    let bedTime: String?
    let wakeTime: String?
    let notificationTime: String?
    let isAlarmEnabled: Bool?
    let isNotificationEnabled: Bool?
    let sleepData: [SleepData]?
}
