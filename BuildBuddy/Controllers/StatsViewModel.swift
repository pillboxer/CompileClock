//
//  StatsViewModel.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 19/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class StatsViewModel {
    
    // MARK: - Exposed Properties
    var project: XcodeProject!
    var bypassChecks = false
    
    lazy var longestBuildString: String? = {
        if let longestBuild = project?.longestBuild {
            return "\(String.prettyTime(longestBuild.totalBuildTime)) - \(formatter.string(from: longestBuild.buildDate))"
        }
        return nil
    }()
    
    var peekButtonShouldShow: Bool {
        if !canShowDailyAverage || !canShowAverageBuildTime || !canShowWorkingTimePercentage {
            return true
        }
        return false
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
            return "Shows After \(buildsRemainingUntilShowAverageBuildTime) More Builds"
        }
    }
    
    var dailyAverageBuildsString: String {
        if canShowDailyAverage || bypassChecks {
            return String(format: "%.1f Builds A Day", dailyAverage)
        }
        else {
            return "Shows After \(daysRemainingUntilShowDailyAverageNumberOfBuilds) More Days"
        }
    }
    
    var workingTimePercentageString: String {
        if canShowWorkingTimePercentage || bypassChecks {
            return String(format: "%.2f", workingTimePercentage) + "%"
        }
        else {
            return "Shows After \(daysRemainingUntilShowPercentageOfTimeSpent) More Days"
        }
    }
    
    
    // MARK: - Private Properties
    private let numberOfBuildsNeededForAverageBuildTime = 50
    private let numberOfDaysNeededForDailyAverageNumberOfBuilds = 30
    private let numberOfDaysNeededForPercentageOfTimeSpentBuilding = 50
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    private lazy var canShowAverageBuildTime: Bool = {
        return project.builds.count >= numberOfBuildsNeededForAverageBuildTime
    }()
    
    private lazy var canShowDailyAverage: Bool = {
        project.numberOfDaysWithBuilds >= numberOfDaysNeededForDailyAverageNumberOfBuilds
    }()
    
    private lazy var canShowWorkingTimePercentage: Bool = {
        return project.numberOfDaysWithBuilds >= numberOfDaysNeededForPercentageOfTimeSpentBuilding
    }()
    
    private lazy var buildsRemainingUntilShowAverageBuildTime: Int = {
        return numberOfBuildsNeededForAverageBuildTime - project.builds.count
    }()
    
    private lazy var daysRemainingUntilShowDailyAverageNumberOfBuilds: Int = {
        return numberOfDaysNeededForDailyAverageNumberOfBuilds - project.numberOfDaysWithBuilds
    }()
    
    private lazy var daysRemainingUntilShowPercentageOfTimeSpent: Int = {
        return numberOfDaysNeededForPercentageOfTimeSpentBuilding - project.numberOfDaysWithBuilds
    }()
    
    private var averageBuildTime: Double {
        return project.averageBuildTime
    }
    
    private var dailyAverage: Double {
        return project.dailyAverageNumberOfBuilds
    }
    
    private var workingTimePercentage: Double {
        return project.percentageOfWorkingTimeSpentBuilding
    }
}
