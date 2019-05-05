//
//  SerialAnalysis+ManufactureDate.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-05-05.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Foundation

extension SerialAnalysis {
    struct ManufactureDate {
        static private let weekNumbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "C", "D", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "T", "V", "W", "X", "Y"]
        static private let yearNumbers = ["C", "D", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "V", "W", "X", "Y", "Z"]
        let year: Int, week: Int
        static private let startDateFormatter = { () -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            return formatter
        }()
        static private let endDateFormatter = { () -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter
        }()
        
        init?(serialNumberPart: String) {
            let yearPart = serialNumberPart.prefix(1), weekPart = serialNumberPart.suffix(1)
            guard let yearValueIndex = SerialAnalysis.ManufactureDate.yearNumbers.firstIndex(where: { $0 == yearPart }), let weekValueIndex = SerialAnalysis.ManufactureDate.weekNumbers.firstIndex(where: { $0 == weekPart }) else { return nil }
            print("yr1", 2019 - (Double(SerialAnalysis.ManufactureDate.yearNumbers.count - yearValueIndex) / 2.0), SerialAnalysis.ManufactureDate.yearNumbers.count - yearValueIndex, yearPart)
            year = 2019 - (SerialAnalysis.ManufactureDate.yearNumbers.count - yearValueIndex - 1) / 2
            let isHalfYear = yearValueIndex % 2 > 0
            week = weekValueIndex + (isHalfYear ? 26 : 0) + 1
        }
        
        var description: String {
            return "Week \(NumberFormatter.localizedString(from: week as NSNumber, number: .decimal)), \(year)"
        }
        
        var startDate: Date? {
            let components = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(secondsFromGMT: 0), era: nil, year: nil, month: nil, day: nil, hour: nil, minute: nil, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: week, yearForWeekOfYear: year)
            return components.date
        }
        
        var endDate: Date? {
            return startDate?.addingTimeInterval(60 * 60 * 24 * 7)
        }
        
        var dateRangeText: String? {
            guard let start = startDate, let end = endDate else { return nil }
            return "\(ManufactureDate.startDateFormatter.string(from: start)) to \(ManufactureDate.endDateFormatter.string(from: end))"
        }
        
        var ageText: String? {
            guard let start = startDate, let age = Calendar.current.dateComponents([.day], from: start, to: Date()).day else { return nil }
            return "\(NumberFormatter.localizedString(from: max(0, age - 7) as NSNumber, number: .decimal))–\(NumberFormatter.localizedString(from: age as NSNumber, number: .decimal)) days"
        }
    }
}
