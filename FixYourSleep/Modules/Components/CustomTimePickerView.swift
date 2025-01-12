//
//  CustomTimePickerView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 14.12.2024.
//

import SwiftUI

struct CustomTimePickerView: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    @State var offset: CGFloat = 0
    

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .opacity(1 - (abs(offset) / 300.0))
                .onTapGesture {
                    dismissPicker()
                }
            
            // Time Picker
            VStack {
                HStack {
                    Button("Cancel") {
                        dismissPicker()
                    }
                    Spacer()
                    Button("Done") {
                        dismissPicker()
                    }
                }
                .padding()
                .foregroundColor(.white)
                
                DatePicker("Select Time",
                           selection: $selectedDate,
                           displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
            .background(RoundedRectangle(cornerRadius: 16)
                .fill(Color.darkGray))
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.height > 0 {
                            offset = gesture.translation.height
                        }
                    }
                    .onEnded { gesture in
                        if gesture.translation.height > 100 {
                            dismissPicker()
                        } else {
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
            .padding()
            .transition(.move(edge: .bottom))
            .tint(.white)
        }
    }
    
    private func dismissPicker() {
        withAnimation(.spring()) {
            offset = UIScreen.main.bounds.height
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isPresented = false
                offset = 0
            }
        }
    }
}

// Preview Provider
struct CustomTimePickerView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTimePickerView(
            isPresented: .constant(true),
            selectedDate: .constant(Date())
        )
    }
}
