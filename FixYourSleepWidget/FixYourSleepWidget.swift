//
//  FixYourSleepWidget.swift
//  FixYourSleepWidget
//
//  Created by Elif Parlak on 10.12.2024.
//


import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    // Specify that SimpleEntry is the Entry type
    typealias Entry = SimpleEntry
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), sleepGoal: "23:00")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let sleepGoal = fetchSleepGoal()
        let entry = SimpleEntry(date: Date(), sleepGoal: sleepGoal)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        var entries: [SimpleEntry] = []

        let sleepGoal = fetchSleepGoal()
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, sleepGoal: sleepGoal)
        entries.append(entry)

        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }

    private func fetchSleepGoal() -> String {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.elifbilgeparlak.fixyoursleep") {
            return sharedDefaults.string(forKey: "sleepGoal") ?? "Not Set"
        } else {
            return "Not Set"
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let sleepGoal: String
}

struct FixYourSleepWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            Color.black
            VStack(spacing: 8) {
                if timeUntilSleep <= 0 {
                    Text("Time to sleep! 😴")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text(entry.sleepGoal)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                } else if timeUntilSleep <= 30 {
                    Text("Bedtime soon! 🌙")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.orange)
                    Text("\(timeUntilSleep) min")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.accentColor)
                } else {
                    Text("Next sleep at")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text(entry.sleepGoal)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding()
        }
    }
    
    private var timeUntilSleep: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let sleepDate = formatter.date(from: entry.sleepGoal) else { return 0 }
        
        let calendar = Calendar.current
        let now = Date()
        
        let sleepComponents = calendar.dateComponents([.hour, .minute], from: sleepDate)
        var targetDate = calendar.date(bySettingHour: sleepComponents.hour ?? 0,
                                       minute: sleepComponents.minute ?? 0,
                                       second: 0,
                                       of: now)!
        
        if targetDate < now {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
        }
        
        let difference = calendar.dateComponents([.minute], from: now, to: targetDate)
        return difference.minute ?? 0
    }
    
}


#Preview(as: .systemSmall) {
    FixYourSleepWidget()
} timeline: {
    SimpleEntry(date: .now, sleepGoal: "23:00")
}

