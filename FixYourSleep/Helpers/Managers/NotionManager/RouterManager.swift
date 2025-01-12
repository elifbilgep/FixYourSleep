//
//  Routermanager.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 3.12.2024.
//

import Foundation
import SwiftUI

final class RouterManager: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    enum Destination: Codable, Hashable {
        case welcome
        case splash
        case home
        case signUp
        case signIn
        case onBoarding
        case sleep
        case editRoutineView
    }
    
    func navigateTo(to destination: Destination) {
        navigationPath.append(destination)
    }
    
    func navigateBack() {
        navigationPath.removeLast()
    }
    
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    func isBackAvailable() -> Bool {
        return !navigationPath.isEmpty
    }
}
