//
//  Double+Extensions.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 07/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

extension Double {

    var minutes: Double {
        return self / 60
    }

    var hours: Double {
        return self / 60 / 60
    }

    var days: Double {
        return self / 60 / 60 / 24
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
    
    var prettyTime: (time: Double, timeBlock: String.TimeBlock) {
        if self.isGreaterThanADay {
            return (self.days, .days)
        }
        else if self.isGreaterThanAnHour {
            return (self.hours, .hours)
        }
        else if self.isGreaterThanAMinute {
            return (self.minutes, .minutes)
        }
        else {
            return (self, .seconds)
        }
    }
}
