//
//  SerialAnalysis+ManufactureDate.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-05-05.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Foundation

public extension SerialAnalysis {
    struct ManufactureDate {
        static private let weekNumbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "C", "D", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "T", "V", "W", "X", "Y"]
        static private let yearNumbers = ["C", "D", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "V", "W", "X", "Y", "Z"]
        
        public let year: Int, week: Int
        
        public init?(serialNumberPart: String) {
            let yearPart = serialNumberPart.prefix(1), weekPart = serialNumberPart.suffix(1)
            guard let yearValueIndex = SerialAnalysis.ManufactureDate.yearNumbers.firstIndex(where: { $0 == yearPart }), let weekValueIndex = SerialAnalysis.ManufactureDate.weekNumbers.firstIndex(where: { $0 == weekPart }) else { return nil }
            print("yr1", 2019 - (Double(SerialAnalysis.ManufactureDate.yearNumbers.count - yearValueIndex) / 2.0), SerialAnalysis.ManufactureDate.yearNumbers.count - yearValueIndex, yearPart)
            year = 2019 - (SerialAnalysis.ManufactureDate.yearNumbers.count - yearValueIndex - 1) / 2
            let isHalfYear = yearValueIndex % 2 > 0
            week = weekValueIndex + (isHalfYear ? 26 : 0) + 1
        }
        
        public var description: String {
            return "Week \(NumberFormatter.localizedString(from: week as NSNumber, number: .decimal)), \(year)"
        }
        
        public var startDate: Date? {
            let components = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(secondsFromGMT: 0), era: nil, year: nil, month: nil, day: nil, hour: nil, minute: nil, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: week, yearForWeekOfYear: year)
            return components.date
        }
        
        public var endDate: Date? {
            return startDate?.addingTimeInterval(60 * 60 * 24 * 7)
        }
    }
}
