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

    enum TimeBlock: String, CaseIterable {
        case automatic
        case seconds
        case minutes
        case hours
        case days
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
    
    static func prettyTime(_ time: Double) -> String {
        let timeValue = time.prettyTime.time
        let timeBlock = time.prettyTime.timeBlock
        return String(format: "%.1f \(timeBlock.rawValue)", timeValue)
    }

    static func formattedTime(_ time: Double, forPeriod period: String.BuildTimePeriod) -> String {
        
        guard time > 0 else {
            return formattedStringForNoBuilds(withPeriod: period)
        }
        let blockForPeriod = UserDefaults.timeBlockForPeriod(period)
        let timeValue: Double
        switch blockForPeriod {
        case .days:
            timeValue = time.days
        case .hours:
            timeValue = time.hours
        case .minutes:
            timeValue = time.minutes
        case .seconds:
            timeValue = time
        case .automatic:
            return prettyTime(time)
        }
        return String(format: "%.1f \(blockForPeriod.rawValue)", timeValue)
    }
    
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
    
    static func menuItemTitleFormatter(withPeriod period: String.BuildTimePeriod, numberOfBuilds: Int) -> String {
        let buildOrBuilds = numberOfBuilds == 1 ? "Build" : "Builds"
        if period == .last {
            return period.pretty
        }
        return "\(period.pretty) - \(numberOfBuilds) \(buildOrBuilds)"
    }
    
    static var xcodeProject = "XcodeProject"


}
