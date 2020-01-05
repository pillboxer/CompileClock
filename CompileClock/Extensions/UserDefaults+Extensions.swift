//
//  UserDefaults+Extensions.swift
//  CompileClock
//
//  Created by Henry Cooper on 09/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum DefaultsBoolKey: String, CaseIterable {
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
        case showsDisplayText
    }
    
    private enum DefaultsDateKey: String, CaseIterable {
        case customStartDate
        case customEndDate
        case lastHelpRequestDate
    }
    
    enum DefaultsStepperKey: String, CaseIterable {
        case daysWorkedPerYear = "Days Worked Per Year"
        case hoursWorkedPerDay = "Hours Worked Per Day"
    }
    
    enum DefaultsAdvancedKey: String, CaseIterable {
        case derivedDataLocation = "Derived Data Location"
        case menuBarText = "Menu Bar Text"
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
        return Date(timeIntervalSinceReferenceDate: date)
    }
    
    private static func set(_ block: String.TimeBlock) {
        for period in String.BuildTimePeriod.allCases {
            UserDefaults.standard.set(block.rawValue.capitalized, forKey: period.rawValue)
        }
    }
    
    private static func getStepperValueForKey(_ key: DefaultsStepperKey) -> Int {
        return UserDefaults.standard.integer(forKey: key.rawValue)
    }

    static private func setInitialCustomDate() {
        let dateInt = Date().timeIntervalSinceReferenceDate
        UserDefaults.standard.set(dateInt, forKey: DefaultsDateKey.customStartDate.rawValue)
        UserDefaults.standard.set(dateInt, forKey: DefaultsDateKey.customEndDate.rawValue)
    }
    
    static private func setInitialDaysWorkedPerYear() {
        UserDefaults.standard.set(262, forKey: UserDefaults.DefaultsStepperKey.daysWorkedPerYear.rawValue)
    }
    
    static private func setInitialHoursWorkedPerDay() {
        UserDefaults.standard.set(8, forKey: UserDefaults.DefaultsStepperKey.hoursWorkedPerDay.rawValue)
    }
    
    static private func setInitialTodayText() {
        UserDefaults.standard.set(true, forKey: UserDefaults.DefaultsBoolKey.showsDisplayText.rawValue)
        UserDefaults.standard.set(String.DisplayTextOptions.builds.rawValue.capitalized, forKey: UserDefaults.DefaultsAdvancedKey.menuBarText.rawValue)
    }
    
    // MARK: - Getters
    
    static var numberOfDaysWorkedPerYear: Int {
        return getStepperValueForKey(.daysWorkedPerYear)
    }
    
    static var hoursWorkedPerDay: Int {
        return getStepperValueForKey(.hoursWorkedPerDay)
    }
    
    static var customStartDate: Date {
        return get(.customStartDate)
    }
    
    static var customEndDate: Date {
        return get(.customEndDate)
    }
    
    static var lastHelpRequestDate: Date {
        get {
            return get(.lastHelpRequestDate)
        }
        set {
            UserDefaults.standard.set(newValue.timeIntervalSinceReferenceDate, forKey: DefaultsDateKey.lastHelpRequestDate.rawValue)
        }
    }
    
    static func get(_ period: String.BuildTimePeriod) -> Bool {
        return UserDefaults.standard.bool(forKey: period.defaultsBoolKey.rawValue)
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
    
    static var showsDisplayText: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.DefaultsBoolKey.showsDisplayText.rawValue)
    }
    
    static var displayTextOption: String.DisplayTextOptions {
        guard let option = UserDefaults.standard.value(forKey: UserDefaults.DefaultsAdvancedKey.menuBarText.rawValue) as? String else {
            setInitialTodayText()
            return .builds
        }
        return String.DisplayTextOptions(rawValue: option.lowercased()) ?? .builds
    }
    
    static var allKeys: [String] {
        let periodKeys = (String.BuildTimePeriod.allCases).map() { $0.rawValue }
        let boolKeys = (DefaultsBoolKey.allCases).map() { $0.rawValue }
        let dateKeys = (DefaultsDateKey.allCases).map() { $0.rawValue }
        let advancedKeys = (DefaultsAdvancedKey.allCases).map() { $0.rawValue }
        return periodKeys + boolKeys + dateKeys + advancedKeys
    }

    
    static var hasLaunchedBefore: Bool {
        get {
          UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasLaunchedBefore")
        }
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
    
    static var derivedDataURL: URL? {
        guard let data = UserDefaults.standard.data(forKey: DefaultsAdvancedKey.derivedDataLocation.rawValue) else {
            return FileManager.standardXcodeFolder 
        }
        var notTrue = true
        do {
            let url = try URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &notTrue)
            return url
        }
        catch let error {
            print(error.localizedDescription)
        }
        return nil
        
    }
    
    // MARK: - Setters
    static func saveDerivedDataURL(_ url: URL) {
        guard let bookmark = try? url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil) else {
            let libraryFolder = FileManager.libraryFolder ?? ""
            let standardDerivedDataLocation = URL(fileURLWithPath: "\(libraryFolder)/DerivedData/")
            UserDefaults.standard.setValue(standardDerivedDataLocation.absoluteString, forKey: DefaultsAdvancedKey.derivedDataLocation.rawValue)
            return
        }
        UserDefaults.standard.set(bookmark, forKey: DefaultsAdvancedKey.derivedDataLocation.rawValue)
    }
    
    static func set(startDate: Date, endDate: Date) {
        UserDefaults.standard.set(startDate.timeIntervalSinceReferenceDate, forKey: DefaultsDateKey.customStartDate.rawValue)
        UserDefaults.standard.set(endDate.timeIntervalSinceReferenceDate, forKey: DefaultsDateKey.customEndDate.rawValue)
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
        setInitialCustomDate()
        setInitialDaysWorkedPerYear()
        setInitialHoursWorkedPerDay()
        setInitialTodayText()
        set(.automatic)
    }
    
}
