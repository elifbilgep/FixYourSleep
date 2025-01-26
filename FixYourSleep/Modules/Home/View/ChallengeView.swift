//
//  ChallengeView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 26.01.2025.
//

import SwiftUI

struct ChallengeView: View {
    var challengeType: ChallengeType
    var goalTime: String
    
    enum ChallengeType {
        case wakeUp, sleep
        
        var title: String {
            switch self {
            case .wakeUp:
                "Get enough sleep to recharge your body"
            case .sleep:
                "Start your day with energy and focus"
            }
        }
        
        var subTitle: String {
            switch self {
            case .wakeUp:
                "Wake up 5 more days to complete weekly goal"
            case .sleep:
                "Sleep 5 more days to complete weekly goal"
            }
        }
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(hex: "1C1B3A"), location: 0.0),
                        Gradient.Stop(color: Color(hex: "010103"), location: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 160)
            .overlay {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: challengeType == .sleep ? "moon.fill" : "sun.max.fill")
                            .font(.system(size: 16))
                        Text("\(goalTime)")
                            .font(.albertSans(.semibold, size: 14))
                        Spacer()
                    }
                    Text(challengeType.title)
                        .font(.albertSans(.semibold, size: 12))
                    LinearProgressView(progress: 0)
                    Text(challengeType.subTitle)
                        .font(.albertSans(.bold, size: 8))
                        .foregroundStyle(.gray)
                }
                .padding()
            }
    }
}

