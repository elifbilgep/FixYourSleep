//
//  FixYourSleepWidgetBundle.swift
//  FixYourSleepWidget
//
//  Created by Elif Parlak on 10.12.2024.
//

import WidgetKit
import SwiftUI

@main
struct FixYourSleepWidget: Widget {
    let kind: String = "FixYourSleepWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FixYourSleepWidgetEntryView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Sleep Time")
        .description("Shows your upcoming sleep time")
        .supportedFamilies([.systemSmall])
        .supportedFamilies([.systemMedium])
    }
}
