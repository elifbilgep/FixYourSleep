//
//  RotatinfShadowModifier.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 9.12.2024.
//

import Foundation
import SwiftUI
import UIKit

enum ShadowSize {
    case small
    case normal
    case large
    
    var radius: CGFloat {
        switch self {
        case .small: return 5
        case .normal: return 20
        case .large: return 30
        }
    }
    
    var offset: CGFloat {
        switch self {
        case .small: return 5
        case .normal: return 20
        case .large: return 30
        }
    }
}
struct RotatingShadowModifier: ViewModifier {
    let size: ShadowSize
    let primaryColor: Color
    let secondaryColor: Color
    @State private var animationOffset: CGFloat = 0

    init(size: ShadowSize = .normal, primaryColor: Color, secondaryColor: Color) {
        self.size = size
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }

    func body(content: Content) -> some View {
        content
            .shadow(
                color: primaryColor.opacity(0.7),
                radius: size.radius,
                x: animationOffset,
                y: animationOffset
            )
            .shadow(
                color: secondaryColor.opacity(0.7),
                radius: size.radius,
                x: -animationOffset,
                y: -animationOffset
            )
            .onAppear {
                // Start animating the shadow offset
                withAnimation(
                    Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)
                ) {
                    animationOffset = size.offset
                }
            }
    }
}


func extractDominantColors(from imageName: String) -> (Color, Color) {
    guard let uiImage = UIImage(named: imageName),
          let cgImage = uiImage.cgImage else {
        return (.blue, .purple) // Default colors
    }
    
    let bitmap = BitmapAnalyzer(image: cgImage)
    let colors = bitmap.dominantColors(count: 2)
    
    let primaryColor = Color(uiColor: UIColor(cgColor: colors.first ?? UIColor.black.cgColor))
    let secondaryColor = Color(uiColor: UIColor(cgColor: colors.last ?? UIColor.white.cgColor))
    
    return (primaryColor, secondaryColor)
}



class BitmapAnalyzer {
    private let image: CGImage
    private let width: Int
    private let height: Int
    
    init(image: CGImage) {
        self.image = image
        self.width = image.width
        self.height = image.height
    }
    
    func dominantColors(count: Int = 2) -> [CGColor] {
        guard let pixelData = createPixelData() else { return [] }
        
        // Create a dictionary to store color frequencies
        var colorFrequency: [CGColor: Int] = [:]
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4
                let r = pixelData[pixelIndex]
                let g = pixelData[pixelIndex + 1]
                let b = pixelData[pixelIndex + 2]
                let a = pixelData[pixelIndex + 3]
                
                guard a > 0 else { continue } // Skip transparent pixels
                
                let color = CGColor(red: CGFloat(r) / 255.0,
                                    green: CGFloat(g) / 255.0,
                                    blue: CGFloat(b) / 255.0,
                                    alpha: 1.0)
                
                colorFrequency[color, default: 0] += 1
            }
        }
        
        // Sort colors by frequency and return the top `count` colors
        return Array(colorFrequency.keys.sorted { colorFrequency[$0]! > colorFrequency[$1]! }.prefix(count))
    }
    
    private func createPixelData() -> [UInt8]? {
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        let context = CGContext(data: &pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let ctx = context else { return nil }
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixelData
    }
}
