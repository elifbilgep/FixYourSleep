//
//  Date+Extension.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 11.01.2025.
//

import Foundation

extension Date {
    func dateToHHMM() -> String {
        let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
        return timeFormatter.string(from: self)
    }
    
    static let hhmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

extension DateFormatter {
    static let hhmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
