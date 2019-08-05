//
//  String+Extensions.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 07/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import Gzip
extension String {
    
    // MARK: - Enums
    enum TimeBlock: String, CaseIterable {
        case automatic
        case seconds
        case minutes
        case hours
        case days
        
        var shortened: String {
            return String(self.rawValue.prefix(1))
        }
    }
    
    enum DisplayTextOptions: String, CaseIterable {
        case builds
        case time
    }
    
    enum BuildTimePeriod: String, CaseIterable {
        case today
        case week
        case allTime = "all time"
        case last = "last build time"
        case custom
        
        var defaultsBoolKey: UserDefaults.DefaultsBoolKey {
            switch self {
            case .today:
                return UserDefaults.DefaultsBoolKey.showsTodayInMenu
            case .week:
                return UserDefaults.DefaultsBoolKey.showsWeekInMenu
            case .allTime:
                return  UserDefaults.DefaultsBoolKey.showsAllTimeInMenu
            case .last:
                return  UserDefaults.DefaultsBoolKey.showsLastInMenu
            case .custom:
                return  UserDefaults.DefaultsBoolKey.showsCustomInMenu
            }
        }
        var pretty: String {
            return self.rawValue.capitalized
        }
    
    }
    
    // MARK: - Exposed Methods
    static func prettyTime(_ time: Double, shortened: Bool = false) -> String {
        let timeValue = time.prettyTime.time
        let timeBlock = time.prettyTime.timeBlock
        let timeBlockValue = shortened ? timeBlock.shortened : timeBlock.rawValue
        let decimalPlaces = Int(UserDefaults.customDecimalPlaces)
        let timeString = String(format: "%.\(decimalPlaces)f \(timeBlockValue)", timeValue)
        return shortened ? timeString.replacingOccurrences(of: " ", with: "") : timeString
    }

    static func formattedTime(_ time: Double, forPeriod period: String.BuildTimePeriod) -> String {
        
        guard time > 0 else {
            return formattedStringForNoBuilds(withPeriod: period)
        }
        let blockForPeriod = UserDefaults.timeBlockForPeriod(period)
        let timeValue: Double
        switch blockForPeriod {
        case .days:
            timeValue = time.daysFromSeconds
        case .hours:
            timeValue = time.hoursFromSeconds
        case .minutes:
            timeValue = time.minutesFromSeconds
        case .seconds:
            timeValue = time
        case .automatic:
            return prettyTime(time)
        }
        let decimalPlaces = UserDefaults.customDecimalPlaces
        return String(format: "%.\(decimalPlaces)f \(blockForPeriod.rawValue)", timeValue)
    }
    
    static func menuItemTitleFormatter(withPeriod period: String.BuildTimePeriod, numberOfBuilds: Int) -> String {
        let buildOrBuilds = numberOfBuilds == 1 ? "Build" : "Builds"
        if period == .last {
            return period.pretty
        }
        return "\(period.pretty) - \(numberOfBuilds) \(buildOrBuilds)"
    }
    
    static var xcodeProject = "XcodeProject"
    
    // MARK: - Private Methods
    private static func formattedStringForNoBuilds(withPeriod period: String.BuildTimePeriod) -> String {
        let noBuilds = "No Builds "
        switch period {
        case .today:
            return noBuilds + "Today"
        case .week:
            return noBuilds + "This Week"
        case .custom:
            return noBuilds + "In This Range"
        default:
            return noBuilds
        }
    }



}

