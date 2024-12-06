//
//  CustomFields.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 4.12.2024.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundStyle(.gray)
                    }
            } else {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundStyle(.gray)
                    }
            }
        }
        .font(.albertSans(.regular, size: 16))
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(UIColor.darkGray).opacity(0.3))
        .cornerRadius(12)
    }

}
