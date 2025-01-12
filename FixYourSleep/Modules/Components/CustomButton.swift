//
//  CustomButton.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 3.12.2024.
//

import SwiftUI

struct CustomButton: View {
    enum Size {
        case small
        case medium
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 16
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            }
        }
        
        var width: CGFloat {
            switch self {
            case .small: return 200
            case .medium: return UIScreen.screenWidth - 48 
            }
        }
    }
    
    let title: String
    let action: () -> Void
    var isSecondary: Bool = false
    var size: Size = .medium
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.albertSans(.medium, size: size.fontSize))
                .foregroundColor(isSecondary ? .white : Color(hex: "1C1B3A"))
                .frame(width: size.width)
                .padding(.vertical, size.verticalPadding)
                .background(
                    isSecondary ? Color(hex: "1C1B3A") : .white
                )
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    CustomButton(title: "Continue") {
    }
}
