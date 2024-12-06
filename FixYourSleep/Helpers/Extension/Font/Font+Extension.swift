//
//  Font+Extension.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 3.12.2024.
//

import SwiftUI

extension Font {
    static func albertSans(_ style: AlbertSansStyle, size: CGFloat) -> Font {
        return .custom("AlbertSans-\(style.rawValue)", size: size)
    }
    
    enum AlbertSansStyle: String {
        case bold = "Bold"
        case light = "Light"
        case medium = "Medium"
        case regular = "Regular"
        case semibold = "Semibold"
        case thin = "Thin"
    }
}

