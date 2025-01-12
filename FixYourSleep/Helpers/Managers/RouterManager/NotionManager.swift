//
//  NotionManager.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 4.12.2024.
//

import Foundation
import CoreMotion
import SwiftUI

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var x = 0.0
    @Published var y = 0.0
    
    init() {
        motionManager.deviceMotionUpdateInterval = 1/60
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let motion = data?.attitude else { return }
            self?.x = motion.roll
            self?.y = motion.pitch
        }
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

struct ParallaxMotionModifier: GeometryEffect {
    var x: CGFloat
    var y: CGFloat
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(x, y) }
        set {
            x = newValue.first
            y = newValue.second
        }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translationX = x * 10
        let translationY = y * 10
        
        let affineTransform = CGAffineTransform(translationX: translationX, y: translationY)
        return ProjectionTransform(affineTransform)
    }
}
