//
//  SleepDataService.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 8.12.2024.
//

import Foundation

protocol SleepDataServiceProtocol {
    func addSleepData(_ sleepData: SleepData, for userId: String) async -> Result<SleepData, Error>
    func getSleepData(for userId: String) async -> Result<[SleepData], Error>
    func updateSleepData(_ sleepData: SleepData, for userId: String) async -> Result<SleepData, Error>
    func deleteSleepData(_ sleepData: SleepData, for userId: String) async -> Result<Void, Error>
}

class SleepDataService: SleepDataServiceProtocol {
    private let firebaseService: FirebaseServiceProtocol
    private let userService: UserServiceProtocol
    
    init(firebaseService: FirebaseServiceProtocol, userService: UserServiceProtocol) {
        self.firebaseService = firebaseService
        self.userService = userService
    }
    
    func addSleepData(_ sleepData: SleepData, for userId: String) async -> Result<SleepData, Error> {
        
        // Önce mevcut kullanıcıyı al
        let userResult = await userService.getUser(id: userId)
        switch userResult {
        case .success(var user):
            // Eğer sleepData array'i yoksa oluştur
            if user.sleepData == nil {
                user.sleepData = []
            }
            
            // Aynı gün için kayıt var mı kontrol et
            if let existing = user.sleepData?.first(where: {
                Calendar.current.isDate($0.date, inSameDayAs: sleepData.date)
            }) {
                return .failure(NSError(domain: "", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Bu gün için zaten kayıt mevcut"]))
            }
            
            // Yeni sleep data'yı ekle
            user.sleepData?.append(sleepData)
            
            // Kullanıcıyı güncelle
            let updateResult = await userService.updateUser(user)
            switch updateResult {
            case .success(_):
                return .success(sleepData)
            case .failure(let error):
                return .failure(error)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getSleepData(for userId: String) async -> Result<[SleepData], Error> {
        let userResult = await userService.getUser(id: userId)
        switch userResult {
        case .success(let user):
            return .success(user.sleepData ?? [])
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func updateSleepData(_ sleepData: SleepData, for userId: String) async -> Result<SleepData, Error> {
        let userResult = await userService.getUser(id: userId)
        switch userResult {
        case .success(var user):
            // Sleep data array'inde güncelleme yap
            if let index = user.sleepData?.firstIndex(where: { $0.id == sleepData.id }) {
                user.sleepData?[index] = sleepData
                
                // Kullanıcıyı güncelle
                let updateResult = await userService.updateUser(user)
                switch updateResult {
                case .success(_):
                    return .success(sleepData)
                case .failure(let error):
                    return .failure(error)
                }
            } else {
                return .failure(NSError(domain: "", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Güncellenecek kayıt bulunamadı"]))
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func deleteSleepData(_ sleepData: SleepData, for userId: String) async -> Result<Void, Error> {
        let userResult = await userService.getUser(id: userId)
        switch userResult {
        case .success(var user):
            // Sleep data'yı array'den kaldır
            user.sleepData?.removeAll(where: { $0.id == sleepData.id })
            
            // Kullanıcıyı güncelle
            let updateResult = await userService.updateUser(user)
            switch updateResult {
            case .success(_):
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
}
