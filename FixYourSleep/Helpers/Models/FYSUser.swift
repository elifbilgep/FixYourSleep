//
//  FYSUser.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 5.12.2024.
//

import Foundation

struct FYSUser: FirebaseIdentifiable, Hashable {
    var id: String
    let userName: String
    let email: String
    let goalSleepingTime: String?
    let notificationTime: String?
    let isAlarmEnabled: Bool?
    let isNotificationEnabled: Bool?
}
 