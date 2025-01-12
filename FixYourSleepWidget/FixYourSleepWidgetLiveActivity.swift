//
//  FixYourSleepWidgetLiveActivity.swift
//  FixYourSleepWidget
//
//  Created by Elif Parlak on 10.12.2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FixYourSleepWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FixYourSleepWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FixYourSleepWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FixYourSleepWidgetAttributes {
    fileprivate static var preview: FixYourSleepWidgetAttributes {
        FixYourSleepWidgetAttributes(name: "World")
    }
}

extension FixYourSleepWidgetAttributes.ContentState {
    fileprivate static var smiley: FixYourSleepWidgetAttributes.ContentState {
        FixYourSleepWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FixYourSleepWidgetAttributes.ContentState {
         FixYourSleepWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FixYourSleepWidgetAttributes.preview) {
   FixYourSleepWidgetLiveActivity()
} contentStates: {
    FixYourSleepWidgetAttributes.ContentState.smiley
    FixYourSleepWidgetAttributes.ContentState.starEyes
}
