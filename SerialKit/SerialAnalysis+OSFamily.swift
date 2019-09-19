//
//  SerialAnalysis+OSFamily.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-05-05.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Foundation

public extension SerialAnalysis {
    enum OSFamily: String, CaseIterable {
        case iOS = "ios", macOS = "macos", tvOS = "tvos", watchOS = "watchos", audioOS = "audioos"
        
        private var deviceNameMatches: [String] {
            switch self {
            case .iOS: return ["iphone", "ipad", "ipod touch"]
            case .macOS: return ["mac", "xserve"]
            case .tvOS: return ["apple tv"]
            case .watchOS: return ["apple watch"]
            case .audioOS: return ["homepod"]
            }
        }
        
        public var friendlyName: String {
            switch self {
            case .iOS: return "iOS"
            case .macOS: return "macOS"
            case .tvOS: return "tvOS"
            case .watchOS: return "watchOS"
            case .audioOS: return "audioOS"
            }
        }
        
        public func matches(deviceName: String) -> Bool {
            let name = deviceName.lowercased()
            return deviceNameMatches.contains { name.contains($0) }
        }
        
        public static func from(deviceName: String) -> OSFamily? {
            return OSFamily.allCases.first { $0.matches(deviceName: deviceName) }
        }
    }
}
