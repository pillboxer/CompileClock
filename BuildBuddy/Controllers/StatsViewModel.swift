//
//  StatsViewModel.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 19/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class StatsViewModel {
    
    
    // MARK: - Properties
    var project: XcodeProject!
    let numberOfBuildsNeededForAverageBuildTime = 50
    let numberOfDaysNeededForDailyAverageNumberOfBuilds = 30
    let numberOfDaysNeededForPercentageOfTimeSpentBuilding = 50
    var bypassChecks = false
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var longestBuildString: String? {
        if let longestBuild = project?.longestBuild {
            return "\(String.prettyTime(longestBuild.totalBuildTime)) - \(formatter.string(from: longestBuild.buildDate))"
        }
        return nil
    }
    
    var peekButtonShouldShow: Bool {
        
        if !canShowDailyAverage || !canShowAverageBuildTime || !canShowWorkingTimePercentage {
            return true
        }
        
        return false
        
    }
    
    private var canShowAverageBuildTime: Bool {
        return project.builds.count >= numberOfBuildsNeededForAverageBuildTime
    }
    
    private var canShowDailyAverage: Bool {
        project.numberOfDaysWithBuilds >= numberOfDaysNeededForDailyAverageNumberOfBuilds
    }
    
    private var canShowWorkingTimePercentage: Bool {
        return project.numberOfDaysWithBuilds >= numberOfDaysNeededForPercentageOfTimeSpentBuilding
    }
    
    private var buildsRemainingUntilShowAverageBuildTime: Int {
        return numberOfBuildsNeededForAverageBuildTime - project.builds.count
    }
    
    private var daysRemainingUntilShowDailyAverageNumberOfBuilds: Int {
        return numberOfDaysNeededForDailyAverageNumberOfBuilds - project.numberOfDaysWithBuilds
    }
    
    private var daysRemainingUntilShowPercentageOfTimeSpent: Int {
        return numberOfDaysNeededForPercentageOfTimeSpentBuilding - project.numberOfDaysWithBuilds
    }
    
    private var averageBuildTime: Double {
        return project.averageBuildTime
    }
    
    private var dailyAverage: Double {
        return project.dailyAverageNumberOfBuilds
    }
    
    private var workingTimePercentage: Double {
        return project.percentageOfWorkingTimeSpentBuilding
    }
    
    var mostBuildsInADayString: String? {
        guard let mostBuilds = project.mostBuildsInADay else {
            return nil
        }
        return "\(mostBuilds.recurrances) - \(formatter.string(from: mostBuilds.date))"
    }
    
    var averageBuildTimeString: String {
        if canShowAverageBuildTime || bypassChecks {
            return String.prettyTime(averageBuildTime)
        }
        else {
            return "Shows After \(numberOfBuildsNeededForAverageBuildTime) More Builds"
        }
    }
    
    var dailyAverageBuildsString: String {
        if canShowDailyAverage || bypassChecks {
            let decimals = UserDefaults.customDecimalPlaces
            return String(format: "%.\(decimals)f Builds A Day", dailyAverage)
        }
        else {
           return "Shows After \(daysRemainingUntilShowDailyAverageNumberOfBuilds) More Days"
        }
    }
    
    var workingTimePercentageString: String {
        if canShowWorkingTimePercentage || bypassChecks {
            let decimals = UserDefaults.customDecimalPlaces
            return String(format: "%.\(decimals)f", workingTimePercentage) + "%"
        }
        else {
            return "Shows After \(daysRemainingUntilShowPercentageOfTimeSpent) More Days"

        }
    }
    
}
