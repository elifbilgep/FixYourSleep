//
//  CustomBackButton.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 25.12.2024.
//

import SwiftUI

struct CustomBackButton: View {
    @EnvironmentObject private var router: RouterManager

    var body: some View {
        HStack {
            Image(systemName: "arrow.backward")
            Text("Back")
                .font(.albertSans(.medium, size: 20))
            Spacer()
        }
        .onTapGesture {
            router.navigateBack()
        }
    }
}

#Preview {
    CustomBackButton()
}
