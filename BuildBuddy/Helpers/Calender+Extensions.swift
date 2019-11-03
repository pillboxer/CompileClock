//
//  Calender+Extensions.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 28/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

extension Calendar {
    
    static func numberOfDaysBetweenDates(_ date1: Date, _ date2: Date) -> Int {
        let calender = Calendar.current
        let date1 = calender.startOfDay(for: date1)
        let date2 = calender.startOfDay(for: date2)
        let differenceOfDays = calender.dateComponents([.day], from: date1, to: date2).day ?? 0
        return abs(differenceOfDays)
    }
}
