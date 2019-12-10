//
//  String+Extensions.swift
//  CompileClock
//
//  Created by Henry Cooper on 07/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import Gzip
import Cocoa
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
        case builds = "builds today"
        case time = "time today"
        case average = "average today"
        case last
        case allTimeCount = "all time (builds)"
        case allTimeDuration = "all time (duration)"
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
    var tintedForDarkModeIfNecessary: NSAttributedString {
        let color = NSAppearance.isDarkMode ? NSColor.white : NSColor.black
            return NSAttributedString(string: self, attributes: [ NSAttributedString.Key.foregroundColor : color])
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    static func prettyTime(_ time: Double) -> String {
        let timeValue = time.prettyTime
        return prettyTimeFromFullTime(timeValue)
    }
    
    static private func prettyTimeFromFullTime(_ fullTime: Double.FullTimeValue) -> String {
        var string = ""
        if let days = fullTime.days {
            string += "\(days)d:"
        }
        if let hours = fullTime.hours {
            string += "\(hours)h:"
        }
        if let minutes = fullTime.minutes {
            string += "\(minutes)m:"
        }
        if let seconds = fullTime.seconds {
            string += "\(seconds)s"
        }
        return string
    }

    static func formattedTime(_ time: Double, forPeriod period: String.BuildTimePeriod) -> String {
        
        guard time > 0 else {
            return formattedStringForNoBuilds(withPeriod: period)
        }
        let blockForPeriod = UserDefaults.timeBlockForPeriod(period)
        let timeValue: Int
        switch blockForPeriod {
        case .days:
            timeValue = time.daysFromSeconds
        case .hours:
            timeValue = time.hoursFromSeconds
        case .minutes:
            timeValue = time.minutesFromSeconds
        case .seconds:
            timeValue = time.totalSeconds
        case .automatic:
            return prettyTime(time)
        }
        return String(format: "\(timeValue)\(blockForPeriod.shortened)", timeValue)
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

