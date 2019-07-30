//
//  XcodeProject+CoreDataClass.swift
//  BuildTimes
//
//  Created by Henry Cooper on 07/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//
//

import Foundation
import AppKit
import CoreData

@objc(XcodeProject)
public class XcodeProject: NSManagedObject {
    
    // MARK: - Creation And Fetching
    static func createNewProjectWithFolderName(_ folderName: String) -> XcodeProject? {
        let project: XcodeProject
        if let existingProject = existingProjectWithFolderName(folderName) {
            project = existingProject
        }
        else {
            let moc = CoreDataManager.moc
            let entityDescription = NSEntityDescription.entity(forEntityName: String.xcodeProject, in: moc)!
            let newProject = self.init(entity: entityDescription, insertInto: moc)
            newProject.folderName = folderName
            project = newProject
            CoreDataManager.save()
        }
        return project
    }
    
    static func deleteProjectWithFolderName(_ folderName: String) {
        let context = CoreDataManager.moc
        if let project = existingProjectWithFolderName(folderName) {
            context.delete(project)
        }
        CoreDataManager.save()
    }
    
    private static func existingProjectWithFolderName(_ folderName: String) -> XcodeProject? {
        let fetchRequest = NSFetchRequest<XcodeProject>(entityName: String.xcodeProject)
        fetchRequest.predicate = NSPredicate(format: "folderName == %@", folderName)
        return try? CoreDataManager.moc.fetch(fetchRequest).first
    }
    
    static func fetchAll() -> [XcodeProject]? {
        let fetchRequest = NSFetchRequest<XcodeProject>(entityName: String.xcodeProject)
        return try? CoreDataManager.moc.fetch(fetchRequest)
    }
    
    // MARK: - Initialisation
    public override required init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // MARK: - Exposed Properties
    var builds: [XcodeBuild] {
        return xcodeBuilds?.allObjects as? [XcodeBuild] ?? []
    }
    
    var name: String {
        return builds.first?.name ?? "Name Not Found"
    }
    
    var earliestBuildDate: Date {
        // Returns the earliest known build date - used for custom date picker
        let earliest = builds.sorted() { $0.buildDate < $1.buildDate }.first
        return earliest?.buildDate ?? Date()
    }
    
    var longestBuild: XcodeBuild? {
        // Returns the build that took the longest time to compile
        return builds.sorted() { $0.totalBuildTime > $1.totalBuildTime }.first
    }
    
    var dailyAverageNumberOfBuilds: Double {
        // Return how many times a project is built each day, on average
        return totalNumberOfBuilds / Double(numberOfDaysWithBuilds)
    }
    
    var numberOfDaysWithBuilds: Int {
        // Return the number of days that have had builds - used so we know whether to show certain stats
        let dates = builds.map() { $0.buildDate }
        let dateStrings = dates.map() { formatter.string(from: $0) }
        let occurences = dateStrings.map() { ($0, 1) }
        let justDates = occurences.map() { $0.0 }
        let uniqueDates = NSSet(array: justDates)
        return uniqueDates.count
    }
    
    var percentageOfWorkingTimeSpentBuilding: Double {
        let averageTimeSpentBuildingEachDay = averageBuildTime * dailyAverageNumberOfBuilds
        let daysWorked = UserDefaults.numberOfDaysWorkedPerYear
        let timeSpentBuildingInAYearOfWork = averageTimeSpentBuildingEachDay * Double(daysWorked)
        let secondsWorkedPerDay = UserDefaults.hoursWorkedPerDay * 60 * 60
        let overall = daysWorked * secondsWorkedPerDay
        let percentage = (timeSpentBuildingInAYearOfWork / Double(overall)) * 100
        return percentage
    }
    
    var logStoreHasBeenUpdated: Bool {
        let logUpdateTime = FileManager.lastModificationDateForFile(logStoreManifest).timeIntervalSinceReferenceDate
        // If the time of the last update to the log was after the last modification date, then it has been updated
        return logUpdateTime > lastModificationDate
    }
    
    var averageBuildTime: Double {
        return totalBuildTime / totalNumberOfBuilds
    }
    
    var mostBuildsInADay: (date: Date, recurrances: Int)? {
        let dates = builds.map() { $0.buildDate }
        let dateStrings = dates.map() { formatter.string(from: $0) }
        let occurences = dateStrings.map() { ($0, 1) }
        let counts = Dictionary(occurences, uniquingKeysWith: +)
        let highestDateDict = counts.sorted() { $0.value > $1.value }.first
        guard let dict = highestDateDict, let date = formatter.date(from: dict.key) else {
            return nil
        }
        return (date, dict.value)
    }
    
    // MARK: - Private Properties
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    private var totalNumberOfBuilds: Double {
        return Double(builds.count)
    }
    
    private var totalBuildTime: Double {
        let allBuilds = builds.map() { $0.totalBuildTime }
        return allBuilds.reduce(0, +)
    }
    
    private var lastBuild: XcodeBuild? {
        return builds.sorted() { $0.buildDate < $1.buildDate }.last
    }
    
    private var lastBuildTime: Double {
        return lastBuild?.totalBuildTime ?? 0.0
    }
    
    private var logs: [String : Any]? {
        guard let logs = NSDictionary(contentsOfFile: logStoreManifest)?["logs"] as? [String : Any] else {
            return nil
        }
        return logs
    }
    
    private var logStoreManifest: String {
        guard let folderName = folderName else {
            return ""
        }
        return folderName + "/LogStoreManifest.plist"
    }
    
    
    // MARK: - Exposed Methods
    func fetchBuilds() {
        guard let folderName = folderName,
            let logs = logs else {
                return
        }
        for (buildKey, buildDict) in logs {
            // Make sure the build is new, otherwise we don't need to bother with it
            if let buildDict = buildDict as? [String : Any],
                buildDictIsNew(buildDict),
                let newBuild = XcodeBuild(buildDict),
                let typeAndSuccessTuple = XcodeProjectManager.buildTypeAndSuccessTuple(buildKey, fromFolder: folderName) {
                FetchingMenuItemManager.changeTextIfAppropriate()
                newBuild.wasSuccessful = typeAndSuccessTuple.success
                newBuild.buildType = typeAndSuccessTuple.type
                addToXcodeBuilds(newBuild)
            }
        }
        // We can have this here, as even if there are no new builds, we are just replacing the date with the same date!
        lastModificationDate = FileManager.lastModificationDateForFile(logStoreManifest).timeIntervalSinceReferenceDate
        CoreDataManager.save()
    }
    
    func buildsForPeriod(_ period: String.BuildTimePeriod) -> [XcodeBuild]? {
        guard
            let lastBuild = lastBuild else {
                return nil
        }
        var filteredBuilds: [XcodeBuild]
        switch period {
        case .allTime:
            filteredBuilds = builds
        case .today:
            let todaysTimes = builds.filter() { $0.buildDateIsToday }
            filteredBuilds = todaysTimes
        case .week:
            let weeksTimes = builds.filter() { $0.buildDateIsInLastWeek }
            filteredBuilds = weeksTimes
        case .last:
            filteredBuilds = [lastBuild]
        case .custom:
            let startDate = UserDefaults.customStartDate
            let endDate = UserDefaults.customEndDate
            let customBuilds = builds.filter() { $0.buildDate >= startDate && $0.buildDate <= endDate }
            filteredBuilds = customBuilds
            
        }
        // Run the filtered builds against our UserDefaults settings
        return buildsToShow(fromBuilds: filteredBuilds)
    }
    
    func numberOfBuildsForPeriod(_ period: String.BuildTimePeriod) -> Int {
        return buildsForPeriod(period)?.count ?? 0
    }
    
    // MARK: - Private Methods
    private func buildDictIsNew(_ dict: [String : Any]) -> Bool {
        guard let timeStarted = dict["timeStartedRecording"] as? Double else {
            return true
        }
        // We know the build is new if the time of the build happened after our internal last modification date
        return timeStarted > lastModificationDate
    }
    
    private func buildsToShow(fromBuilds builds: [XcodeBuild]) -> [XcodeBuild] {
        return builds.filter() { build in
            // If we don't show tests, archives or cleans and the build is one of those, we hide
            if !UserDefaults.showsBuildType(build.buildType) {
                return false
            }
            // We check if we are showing builds with this result (success or failure)
            return UserDefaults.showsSuccess(build.wasSuccessful)
        }
    }
}
