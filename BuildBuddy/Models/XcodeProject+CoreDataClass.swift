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
    
    // MARK: - Creation
    
    static func createNewProjectWithFolderName(_ folderName: String) -> XcodeProject? {
        let project: XcodeProject
        
        // This can stay the same
        
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
    
    
    // MARK: - Properties
    var builds: [XcodeBuild] {
        return xcodeBuilds?.allObjects as? [XcodeBuild] ?? []
    }
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var name: String {
        return builds.first?.name ?? "Name Not Found"
    }
    
    var earliestBuildDate: Date {
        let earliest = builds.sorted() { $0.buildDate < $1.buildDate }.first
        return earliest?.buildDate ?? Date()
    }
    
    var longestBuild: XcodeBuild? {
        return builds.sorted() { $0.totalBuildTime > $1.totalBuildTime }.first
    }
    
    var dailyAverageNumberOfBuilds: Double {
        return totalNumberOfBuilds / Double(numberOfDaysWithBuilds)
    }
    
    private var numberOfDaysWithBuilds: Int {
        let dates = builds.map() { $0.buildDate }
        let dateStrings = dates.map() { formatter.string(from: $0) }
        let occurences = dateStrings.map() { ($0, 1) }
        let justDates = occurences.map() { $0.0 }
        let uniqueDates = NSSet(array: justDates)
        return uniqueDates.count
    }
    
    var totalAverageBuildTime: Double {
        return totalBuildTime / totalNumberOfBuilds
    }
    
    private var totalNumberOfBuilds: Double {
        return Double(builds.count)
    }
    
    private var totalBuildTime: Double {
        let allBuilds = builds.map() { $0.totalBuildTime }
        return allBuilds.reduce(0, +)
    }
    
    var logStoreHasBeenUpdated: Bool {
        let logUpdateTime = FileManager.lastModificationDateForFile(logStoreManifest).timeIntervalSinceReferenceDate
        print("The log was last updated at: \(Date(timeIntervalSinceReferenceDate: logUpdateTime))")
        print("Our last modified date was at: \(Date(timeIntervalSinceReferenceDate: lastModificationDate))")
        print("Thus Returning \(logUpdateTime > lastModificationDate)")
        print("-----------")
        return logUpdateTime > lastModificationDate
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
    
    
    // Get The Plist to fetch builds
    
    // MARK: - Exposed
    func fetchBuilds() {
        
        // If the log store has not been updated, don't do this expensive task
        guard let folderName = folderName,
            let logs = logs else {
                return
        }
      
        for (buildKey, buildDict) in logs {
            // If the buildDict's end time is before the lastModificationDate, stop!
            if let buildDict = buildDict as? [String : Any],
                buildDictIsNew(buildDict),
                let newBuild = XcodeBuild(buildDict), let typeAndSuccessTuple = XcodeProjectManager.buildTypeAndSuccessTuple(buildKey, fromFolder: folderName) {
                newBuild.wasSuccessful = typeAndSuccessTuple.success
                newBuild.buildType = typeAndSuccessTuple.type
                addToXcodeBuilds(newBuild)
            }
        }
        lastModificationDate = FileManager.lastModificationDateForFile(logStoreManifest).timeIntervalSinceReferenceDate
        CoreDataManager.save()
    }
    
    
    private func buildDictIsNew(_ dict: [String : Any]) -> Bool {
        guard let timeStarted = dict["timeStartedRecording"] as? Double else {
            return true
        }
        return timeStarted > lastModificationDate
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
        return buildsToShow(fromBuilds: filteredBuilds)
    }
    
    func buildsToShow(fromBuilds builds: [XcodeBuild]) -> [XcodeBuild] {
        return builds.filter() { build in
            // If we don't show tests, archives or cleans and the build is one, we hide
            if !UserDefaults.showsBuildType(build.buildType) {
                return false
            }
            
            return UserDefaults.showsSuccess(build.wasSuccessful)
            
            
        }
    }
    
    func numberOfBuildsForPeriod(_ period: String.BuildTimePeriod) -> Int {
        return buildsForPeriod(period)?.count ?? 0
    }
    
    
}
