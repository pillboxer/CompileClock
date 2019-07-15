//
//  UserDefaults+Extensions.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 09/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum DefaultsBoolKey: String, CaseIterable {
        case hasLaunchedBefore
        case showsTodayInMenu
        case showsWeekInMenu
        case showsAllTimeInMenu
        case showsLastInMenu
        case showsCustomInMenu
        case showsTests
        case showsArchives
        case showsCleans
        case showsSucceeded
        case showsFailures
        case showsBuilds
    }
    
    private enum DefaultsDateKey: String, CaseIterable {
        case customStartDate
        case customEndDate
    }
    
    
    
    // MARK: - Private
    
    private static var periodBools: [Bool] {
        var bools = [Bool]()
        for period in String.BuildTimePeriod.allCases {
            bools.append(get(period))
        }
        return bools
    }
    
    private static func get(_ dateKey: DefaultsDateKey) -> Date {
        let date = UserDefaults.standard.double(forKey: dateKey.rawValue)
        guard date != 0 else {
            print("No custom date")
            return Date()
        }
        print(Date(timeIntervalSinceReferenceDate: date))
        return Date(timeIntervalSinceReferenceDate: date)
    }
    
    private static func set(_ block: String.TimeBlock) {
        for period in String.BuildTimePeriod.allCases {
            UserDefaults.standard.set(block.rawValue.capitalized, forKey: period.rawValue)
        }
    }
    
    // MARK: - Getters
    
    static func get(_ period: String.BuildTimePeriod) -> Bool {
        return UserDefaults.standard.bool(forKey: period.defaultsBoolKey.rawValue)
    }
    
    static var customStartDate: Date {
        return get(.customStartDate)
    }
    
    static var customEndDate: Date {
        return get(.customEndDate)
    }
    
    static func showsBuildType(_ buildType: XcodeBuild.BuildType) -> Bool {
        switch buildType {
        case .archive:
            return UserDefaults.standard.bool(forKey: DefaultsBoolKey.showsArchives.rawValue)
        case .clean:
            return UserDefaults.standard.bool(forKey: DefaultsBoolKey.showsCleans.rawValue)
        case .test:
            return UserDefaults.standard.bool(forKey: DefaultsBoolKey.showsTests.rawValue)
        default:
            return UserDefaults.standard.bool(forKey: DefaultsBoolKey.showsBuilds.rawValue)
        }
    }
    
    static func showsSuccess(_ success: Bool) -> Bool {
        switch success {
        case false:
            return UserDefaults.standard.bool(forKey: DefaultsBoolKey.showsFailures.rawValue)
        case true:
            return UserDefaults.standard.bool(forKey: DefaultsBoolKey.showsSucceeded.rawValue)
        }
    }
    
    static var allKeys: [String] {
        let periodKeys = (String.BuildTimePeriod.allCases).map() { $0.rawValue }
        let boolKeys = (DefaultsBoolKey.allCases).map() { $0.rawValue }
        let dateKeys = (DefaultsDateKey.allCases).map() { $0.rawValue }
        return periodKeys + boolKeys + dateKeys
    }

    
    static var hasLaunchedBefore: Bool {
        return UserDefaults.standard.bool(forKey: DefaultsBoolKey.hasLaunchedBefore.rawValue)
    }
    
    static var allPeriodsDisabled: Bool {
        return !periodBools.contains(true)
    }
    
    private static func set(_ key: DefaultsBoolKey, bool: Bool) {
        UserDefaults.standard.set(bool, forKey: key.rawValue)
    }
    
    static func timeBlockForPeriod(_ period: String.BuildTimePeriod) -> String.TimeBlock {
        guard let defaultsValue = UserDefaults.standard.value(forKey: period.rawValue) as? String else {
            return .automatic
        }
        return String.TimeBlock(rawValue: defaultsValue.lowercased()) ?? .automatic
    }
    
    // MARK: - Setters
    
    static func set(startDate: Date, endDate: Date) {
        UserDefaults.standard.set(startDate.timeIntervalSinceReferenceDate, forKey: "customStartDate")
        UserDefaults.standard.set(endDate.timeIntervalSinceReferenceDate, forKey: "customEndDate")
    }
    
    static func setInitialDefaults() {
        for key in DefaultsBoolKey.allCases {
            if key == .showsCustomInMenu {
                set(key, bool: false)
            }
            else {
                set(key, bool: true)
            }
        }
        set(.automatic)
    }
    
}
