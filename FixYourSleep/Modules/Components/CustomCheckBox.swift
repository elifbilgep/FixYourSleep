//
//  CustomCheckBox.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 4.12.2024.
//

import SwiftUI

struct CustomCheckBoxView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isChecked: Bool
    var antiThemeColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var themeColor: Color {
        colorScheme == .dark ? .black : .white
    }
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(antiThemeColor, lineWidth: 1) // Stroke color and width
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isChecked ? antiThemeColor : .clear) // Fill color based on check state
                    )
                    .frame(width: 20, height: 20)
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .foregroundColor(themeColor)
                }
            }
            .padding(4)
        }
    }
}
