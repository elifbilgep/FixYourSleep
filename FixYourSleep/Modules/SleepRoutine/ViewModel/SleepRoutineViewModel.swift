//
//  SleepRoutineViewModel.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 8.12.2024.
//

import Foundation
import UIKit

class SleepRoutineViewModel: ObservableObject {
    //MARK: Properties
    @Published var steps: [Step] = [
        Step(stepTitle: "Turn your phone to no disturb mode", isCompleted: false)
    ]
    @Published var timeRemaining: Int = 10
    @Published var isTimerRunning: Bool = false
    @Published var isBookDetected: Bool = false
    @Published var capturedImage: UIImage? = nil
    private var timer: Timer?


    //MARK: Complete Step and Add Next
    func completeStepAndAddNext(_ index: Int) {
        if index == 2 {
            steps[2].isCompleted = true
        }
        
        if index < steps.count {
            steps[index].isCompleted = true
        }

        switch index {
        case 0:
            steps.append(Step(stepTitle: "Spend 10 mins to relax the mind", isCompleted: false))
        case 1:
            steps.append(Step(stepTitle: "Put your phone on the table", isCompleted: false))
        default:
            break
        }
    }

    //MARK: Start Timer
    func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
            }
        }
    }

    //MARK: Stop Timer
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    //MARK: Format time
    func formatTime() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    //MARK: save user log as sleeped
    func saveUserSleepLog() {
        
    }

}
