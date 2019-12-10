//
//  StatsViewModel.swift
//  CompileClock
//
//  Created by Henry Cooper on 19/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import Cocoa

class StatsViewModel {
    
    // MARK: - Exposed Properties
    struct ComparedPayloadData {
        let comparedAverageTimeString: NSAttributedString
        let comparedLongestString: NSAttributedString
        let comparedPercentageString: NSAttributedString
        let comparedMostString: NSAttributedString
        let comparedAverageBuildsString: NSAttributedString
    }
    
    var project: XcodeProject!
    
    var longestBuildString: String {
        if let longestBuild = project?.longestBuild {
            return "\(String.prettyTime(longestBuild.totalBuildTime)) - \(formatter.string(from: longestBuild.buildDate))"
        }
        return "N/A"
    }
    
    var mostBuildsInADayString: String {
        guard let mostBuilds = project.mostBuildsInADay else {
            return "N/A"
        }
        return "\(mostBuilds.recurrances) - \(formatter.string(from: mostBuilds.date))"
    }
    
    var averageBuildTimeString: String {
        return String.prettyTime(averageBuildTime)
    }
    
    var dailyAverageBuildsString: String {
        return String(format: "%.1f Builds A Day", dailyAverage)
    }
    
    var workingTimePercentageString: String {
        return String(format: "%.2f", workingTimePercentage) + "%"
    }
    
    func comparisonData(_ payload: ProjectsResponse.ProjectComparisonPayload) -> ComparedPayloadData {
        
        let averageTimeString = comparedStringsFromTimes(payload.averageBuildTime, time2: averageBuildTime, comparisonType: .time)
        let percentageString = comparedStringsFromTimes(payload.workingTimePercentage, time2: workingTimePercentage, comparisonType: .quantity)
        let longestString = comparedStringsFromTimes(payload.longestBuildTime, time2: longestBuildTime, comparisonType: .time)
        let averagePerDayString = comparedStringsFromTimes(payload.averageBuildsPerDay, time2: averageBuildsPerDay, comparisonType: .quantity)
        let mostBuildsString = comparedStringsFromTimes(Double(payload.mostBuilds ?? 1), time2: Double(mostBuilds ?? 1), comparisonType: .quantity)
        
        return ComparedPayloadData(comparedAverageTimeString: averageTimeString, comparedLongestString: longestString, comparedPercentageString: percentageString, comparedMostString: mostBuildsString, comparedAverageBuildsString: averagePerDayString)

    }
    
    enum ComparisonType {
        case time
        case quantity
    }
    
    private func comparedStringsFromTimes(_ time1: Double?, time2: Double?, comparisonType: ComparisonType) -> NSAttributedString {
        guard let time1 = time1,
            let time2 = time2 else {
                return NSAttributedString(string: "Could not get average")
        }
        let comparisonString: String
        if comparisonType == .time {
            comparisonString = (time1 > time2) ? "faster" : "slower"
        }
        else {
            comparisonString = (time1 > time2) ? "less" : "more"
        }
        
        let bigger = max(time1, time2)
        let smaller = min(time1, time2)
        let rounded = round(10 * (bigger/smaller)) / 10
        let text = "\(rounded)x \(comparisonString) than average"
        let attributed = NSMutableAttributedString(string: text)

        if comparisonString == "more" || comparisonString == "slower" {
            attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.red, range: NSRange(location: 0, length: text.count))
        }
        else {
            attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.systemGreen, range: NSRange(location: 0, length: text.count))
        }
        
        return attributed
        

    }
    
    // MARK: - Private Properties
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    private var averageBuildTime: Double {
        return project.averageBuildTime
    }

    func compare(completion: @escaping (ProjectsResponse.ProjectComparisonPayload?, APIError?) -> Void) {
        if let uuid = project.uuid {
            DatabaseManager.shared.compareProject(uuid, completion: completion)
        }
        else {
            completion(nil, nil)
        }
    }
    
    private var dailyAverage: Double {
        return project.dailyAverageNumberOfBuilds
    }
    
    private var workingTimePercentage: Double {
        return project.percentageOfWorkingTimeSpentBuilding
    }
    
    private var longestBuildTime: Double? {
        return project.longestBuildTime
    }
    
    private var averageBuildsPerDay: Double? {
        return project.dailyAverageNumberOfBuilds
    }
    
    private var mostBuilds: Int? {
        return project.mostBuildsInADay?.recurrances
    }
}
