//
//  PageFour.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 12.01.2025.
//

import SwiftUI

struct PageFour: View {
    var body: some View {
        VStack(spacing: 50) {
            VStack(alignment: .leading, spacing: 6) {
                Text("When do you want to sleep?")
                    .font(.albertSans(.semibold, size: 40))
                Text("Set your ideal bedtime to wake up feeling refreshed and energized.")
                    .font(.albertSans(.regular, size: 20))
            }
            .padding(.leading, 20)
            .padding(.top, 80)
            .frame(width: UIScreen.screenWidth, alignment: .leading)
            
            VStack {
                Text("Bedtime")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.gray)
                Text(timeFormatter.string(from: bedTime))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showTimePicker = true
                        }
                    }
            }

            VStack {
                Text("Wake-up Time")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.gray)
                Text(timeFormatter.string(from: wakeUpTime))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showWakeUpPicker = true
                        }
                    }
            }

            Spacer()
        }
        .overlay(
            Group {
                if showTimePicker {
                    CustomTimePickerView(
                        isPresented: $showTimePicker,
                        selectedDate: $bedTime
                    )
                }
                if showWakeUpPicker {
                    CustomTimePickerView(
                        isPresented: $showWakeUpPicker,
                        selectedDate: $wakeUpTime
                    )
                }
            }
        )    }
}

#Preview {
    PageFour()
}
