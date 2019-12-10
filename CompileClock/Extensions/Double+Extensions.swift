//
//  Double+Extensions.swift
//  CompileClock
//
//  Created by Henry Cooper on 07/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

extension Double {
    
    typealias FullTimeValue = (days: Int?, hours: Int?, minutes: Int?, seconds: Int?)
    
    var totalSeconds: Int {
        return Int(self)
    }
    
    var seconds: Int {
        return totalSeconds % 60
    }

    var hoursFromSeconds: Int {
        return (totalSeconds % 86400) / 3600
    }

    var daysFromSeconds: Int {
        return (totalSeconds % 31536000) / 86400
    }
    
    var minutesFromSeconds: Int {
        return (totalSeconds % 3600) / 60
    }
    
    var isGreaterThanADay: Bool {
        return self > 86400
    }
    
    var isGreaterThanAnHour: Bool {
        return self > 3600
    }
    
    var isGreaterThanAMinute: Bool {
        return self > 60
    }
    
    var prettyTime: (FullTimeValue) {
        if isGreaterThanADay {
            return (daysFromSeconds, hoursFromSeconds, minutesFromSeconds, seconds)
        }
        else if isGreaterThanAnHour {
            return (nil, hoursFromSeconds, minutesFromSeconds, seconds)
        }
        else if isGreaterThanAMinute {
            return (nil, nil, minutesFromSeconds, seconds)
        }
        else {
            return (nil, nil, nil, seconds)
        }
    }
}
