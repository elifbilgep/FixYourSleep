//
//  Color+Extension.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 3.12.2024.
//

import SwiftUI

extension Color {
    // Hex color initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - App Colors
    static var accentDark: Color { Color("customAccentDark") }
    static var accentLight: Color { Color("customAccentLight") }
    
    // Background colors
    static var blackBackgroundColor: Color { Color("blackBg") }
    
    // Gray scale
    static var darkGrayColor: Color { Color("darkGray") }
    static var lightGrayColor: Color { Color("lightGray") }
    static var sheetGrayColor: Color { Color("sheetGray") }
}
