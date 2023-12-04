//
//  Day.swift
//  caly
//
//  Created by Cristian Cretu on 04.12.2023.
//

import Foundation
import SwiftUI

struct Day: Identifiable {
    let id = UUID()
    let number: String
    let name: String
}

struct DateSequence: Sequence, IteratorProtocol {
    var current: Date
    let end: Date

    mutating func next() -> Date? {
        if current > end { return nil }
        defer { current = Calendar.current.date(byAdding: .day, value: 1, to: current)! }
        return current
    }

    init(from start: Date, to end: Date) {
        self.current = start
        self.end = end
    }
}

func currentWeek() -> [Day] {
    let calendar = Calendar.current
    let today = Date()
    let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: today)!
    
    var days: [Day] = []
    for date in DateSequence(from: weekInterval.start, to: weekInterval.end) {
        let dayNumber = calendar.component(.day, from: date)
        let dayName = calendar.weekdaySymbols[calendar.component(.weekday, from: date) - 1]
        days.append(Day(number: String(format: "%02d", dayNumber), name: dayName))
    }
    return days
}

func generateDays(startingFrom baseDate: Date, offset: Int) -> Day {
    let calendar = Calendar.current
    if let date = calendar.date(byAdding: .day, value: offset, to: baseDate) {
        let dayNumber = calendar.component(.day, from: date)
        let dayName = calendar.weekdaySymbols[calendar.component(.weekday, from: date) - 1]
        return Day(number: String(format: "%02d", dayNumber), name: dayName)
    } else {
        // Fallback in case of an error in date calculation
        return Day(number: "??", name: "Error")
    }
}

