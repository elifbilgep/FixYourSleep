//
//  SleepRoutineViewModel.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 8.12.2024.
//

import Foundation
import AVFoundation

//MARK: ViewModel
class SleepRoutineViewModel: ObservableObject {
    //MARK: Properties
    @Published var steps: [Step] = [
        Step(stepTitle: "Turn your phone to no disturb mode", isCompleted: false)
    ]
    @Published var timeRemaining: Int = 600 // 10 minutes in seconds
    @Published var isTimerRunning: Bool = false
    @Published var selectedSound: String?
    private let soundURLs = [
        "Rain": URL(string: "https://freesound.org/data/previews/531/531497_9198689-lq.mp3")!, // Rain Ambient White Noise
        "Ocean": URL(string: "https://www.orangefreesounds.com/wp-content/uploads/2020/01/Relaxing-white-noise-ocean-waves.mp3")!, // Ocean Waves White Noise
        "White Noise": URL(string: "https://assets.mixkit.co/sfx/preview/mixkit-white-noise-ambience-loop-515.mp3")! // Example White Noise
    ]
    private var timer: Timer?
    private var audioPlayer: AVPlayer?
    
    init(isPreview: Bool = false) {
        // Set 30 seconds for preview, 10 minutes for real use
        self.timeRemaining = isPreview ? 3 : 600
    }
    
    //MARK: Complete Step and Add Next
    func completeStepAndAddNext(_ index: Int) {
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
        
        if index == 2 {
            steps[2].isCompleted = true
        }
    }
    
    //MARK: Start timer
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
    //MARK: Stop timer
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
    
    //MARK: format time
    func formatTime() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    //MARK: Play sound
    func playSound(_ sound: String) {
        if selectedSound == sound {
            // Pause current sound
            audioPlayer?.pause()
            selectedSound = nil
        } else {
            // Stop current sound if any
            audioPlayer?.pause()
            
            // Play new sound
            if let url = soundURLs[sound] {
                let playerItem = AVPlayerItem(url: url)
                
                // Create new audio player if nil or reuse existing
                if audioPlayer == nil {
                    audioPlayer = AVPlayer(playerItem: playerItem)
                } else {
                    audioPlayer?.replaceCurrentItem(with: playerItem)
                }
                
                // Set up looping
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                       object: playerItem,
                                                       queue: .main) { [weak self] _ in
                    self?.audioPlayer?.seek(to: .zero)
                    self?.audioPlayer?.play()
                }
                
                audioPlayer?.volume = 0.5 // Set volume (0.0 to 1.0)
                audioPlayer?.play()
                selectedSound = sound
            }
        }
    }
    
    //MARK: Stop sound
    func stopSound() {
        // Remove observer when stopping
        NotificationCenter.default.removeObserver(self)
        audioPlayer?.pause()
        audioPlayer = nil
        selectedSound = nil
    }
    
    // Add deinit to clean up
    deinit {
        stopSound()
    }
}
