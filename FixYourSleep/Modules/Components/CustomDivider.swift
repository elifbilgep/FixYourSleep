//
//  CustomDivider.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 4.12.2024.
//

import SwiftUI

struct CustomDivider:  View {
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.gray.opacity(0.3))
            
            Text("or")
                .font(.albertSans(.regular, size: 14))
                .foregroundStyle(.gray)
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.gray.opacity(0.3))
        }
    }
}


