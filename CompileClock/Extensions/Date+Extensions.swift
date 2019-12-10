//
//  Date+Extensions.swift
//  CompileClock
//
//  Created by Henry Cooper on 30/08/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

extension Date {
    
    func isWithinLastNumberOfHours(_ numberOfHours: Int) -> Bool {
        guard let difference = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour else {
            return false
        }

        return difference < numberOfHours
    }
    
}
