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
        guard FileManager.folderIsValid(folderName) else {
            return nil
        }
        let project: XcodeProject
        if let existingProject = existingProjectWithFolderName(folderName) {
            project = existingProject
        }
        else {
            let moc = CoreDataManager.moc
            let entityDescription = NSEntityDescription.entity(forEntityName: String.xcodeProject, in: moc)!
            let newProject = self.init(entity: entityDescription, insertInto: moc)
            newProject.isVisible = true
            newProject.folderName = folderName
            project = newProject
            CoreDataManager.saveOnMainThread()
        }
        return project
    }
    
    static func deleteProjectWithFolderName(_ folderName: String) {
        let context = CoreDataManager.moc
        if let project = existingProjectWithFolderName(folderName) {
            context.delete(project)
        }
        CoreDataManager.saveOnMainThread()
    }
    
    static func existingProjectWithFolderName(_ folderName: String, on context: NSManagedObjectContext? = CoreDataManager.moc) -> XcodeProject? {
        let predicate = NSPredicate(format: "folderName == %@", folderName)
        return existingProject(withPredicate: predicate, sortDescriptors: nil, inContext: context)
    }
    
    static func existingProjects(_ context: NSManagedObjectContext = CoreDataManager.moc) -> [XcodeProject]? {
        return existingObjects(withPredicate: nil, sortDescriptors: nil, inContext: context) as? [XcodeProject]
    }
    
    static func existingProjectsWithBuilds(_ context: NSManagedObjectContext = CoreDataManager.moc) -> [XcodeProject]? {
        if let existingProjects = existingProjects(context) {
            return existingProjects.filter() { $0.builds.count > 0 }
        }
        return nil
    }
    
    static func existingProject(withPredicate predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, inContext context: NSManagedObjectContext?) -> XcodeProject? {
        return self.existingObject(withPredicate: predicate, sortDescriptors: sortDescriptors, inContext: context) as? XcodeProject
    }
    
    static func updateProjectsFromResponse(projects: [XcodeProject], response: ProjectsResponse) {
                
        guard let responseArray = response.data,
            responseArray.count == projects.count else {
            return
        }
        for i in 0..<projects.count {
            projects[i].uuid = responseArray[i].uuid
        }
        
    }
    
    static func fetchAll(inContext context: NSManagedObjectContext? = CoreDataManager.moc) -> [XcodeProject]? {
        let fetchRequest = NSFetchRequest<XcodeProject>(entityName: String.xcodeProject)
        return try? context?.fetch(fetchRequest)
    }
    
    // MARK: - Initialisation
    public override required init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // MARK: - Exposed Properties
    var builds: [XcodeBuild] {
        return (xcodeBuilds?.allObjects as? [XcodeBuild] ?? [])
    }
    
    var name: String {
        get {
            if let userDefinedName = userDefinedName {
                return userDefinedName
            }
            else if let closestName = closestName {
                return closestName
            }
            else {
                return builds.first?.name ?? "Name Not Found"
            }
        }
        
        set {
            if let userDefinedName = userDefinedName,
                userDefinedName == newValue {
                return
            }
            userDefinedName = newValue
            XcodeProjectManager.forceProjectUpdate()
            CoreDataManager.saveOnMainThread()
        }
    }

    
    var closestName: String? {
        if let strippedFolder = strippedFolder {
            if hasAlternateNames {
                let nameMatchingFolder = nameAlternatives.filter() { strippedFolder == $0 }.first
                if let matchedName = nameMatchingFolder {
                    return matchedName
                }
            }
        }
        return nil
    }
    
    var nameAlternatives: [String] {
        let nameSet = Set(builds.compactMap() { $0.name } )
        return Array(nameSet)
    }
    
    var hasAlternateNames: Bool {
        return nameAlternatives.count > 1
    }
    
    var strippedFolder: String? {
        guard let folderName = folderName else {
            return nil
        }
        let beforeHyphen = folderName.components(separatedBy: "-")[0]
        let afterSlash = beforeHyphen.components(separatedBy: "/").last
        return afterSlash
    }
    
    var derivedDataFolderName: String? {
        return folderName?.replacingOccurrences(of: "Logs/Build", with: "")
    }
    
    var todaysBuilds: [XcodeBuild] {
        return builds.filter() { $0.buildDateIsToday }
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
    
    var longestBuildTime: Double? {
        return longestBuild?.totalBuildTime
    }
    
    var dailyAverageNumberOfBuilds: Double {
        // Return how many times a project is built each day, on average
        return Double(totalNumberOfBuilds) / Double(numberOfDaysWithBuilds)
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
        let updated = logUpdateTime > lastModificationDate
        if updated {
            LogUtility.updateLogWithEvent(.logStoreManifestUpdated(name))
        }
        return logUpdateTime > lastModificationDate
    }
    
    var averageBuildTime: Double {
        return Double(totalBuildTime) / Double(totalNumberOfBuilds)
    }
    
    
    var todaysBuildTime: Double {
        let times = todaysBuilds.map() { $0.totalBuildTime }
        let totalForToday = times.reduce(0, +)
        return totalForToday
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
    
    var totalNumberOfBuilds: Int {
        return builds.count
    }
    
    var totalBuildTime: Double {
        let allBuilds = builds.map() { $0.totalBuildTime }
        return allBuilds.reduce(0, +)
    }
    
    var lastBuild: XcodeBuild? {
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
        LogUtility.updateLogWithEvent(.fetchingBuilds(name))
        
        guard let folderName = folderName,
            let logs = logs else {
                LogUtility.updateLogWithEvent(.noLogs(name))
                lastModificationDate = FileManager.lastModificationDateForFile(logStoreManifest).timeIntervalSinceReferenceDate
                return
        }
        
        // This method is used in the background, that's why we use the private moc
        let context = CoreDataManager.privateMoc
        let id = objectID
        
        guard let projectForThread = context.object(with: id) as? XcodeProject else {
            return
        }
        context.performAndWait {
            
            var projectNumber = 1
            guard let buildsToFetch = newBuildsFromLogs(logs, forProject: projectForThread, inContext: context) else {
                return
            }
            
            print("NEW BUILDS: \(buildsToFetch.count)")
            
            FetchingMenuItemManager.updateMenuItem(withProjectName: projectForThread.name, projectNumber: projectNumber, numberOfBuilds: buildsToFetch.count)
            
            for (buildKey, build) in buildsToFetch {
                if let typeAndSuccessTuple = XcodeProjectManager.buildTypeAndSuccessTuple(buildKey, fromFolder: folderName) {
                    build.wasSuccessful = typeAndSuccessTuple.success
                    build.buildType = typeAndSuccessTuple.type
                    projectForThread.addToXcodeBuilds(build)
                    projectNumber += 1
                    FetchingMenuItemManager.updateMenuItem(withProjectName: projectForThread.name, projectNumber: projectNumber, numberOfBuilds: buildsToFetch.count)
                    LogUtility.updateLogWithEvent(.newBuild(build.buildDate))
                }
                else {
                    projectForThread.removeFromXcodeBuilds(build)
                }
            }
            
            projectForThread.lastModificationDate = FileManager.lastModificationDateForFile(projectForThread.logStoreManifest).timeIntervalSinceReferenceDate
        }
        
        LogUtility.updateLogWithEvent(.lastModificationDateUpdated(name))
    }
    
    private func newBuildsFromLogs(_ logs: [String: Any], forProject project: XcodeProject, inContext context: NSManagedObjectContext) -> [String: XcodeBuild]? {
        var buildsToFetch = [String : XcodeBuild]()
        for (buildKey, buildDict) in logs {
            guard let buildDict = buildDict as? [String : Any] else {
                return nil
            }
            if project.buildDictIsNew(buildDict),
                let newBuild = XcodeBuild(buildDict, inContext: context) {
                buildsToFetch[buildKey] = newBuild
            }
        }
        return buildsToFetch
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
            filteredBuilds = todaysBuilds
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
    
    func checkAndRemoveDuplicates() {
        guard let xcodeBuilds = xcodeBuilds, let setBuilds = xcodeBuilds as? Set<XcodeBuild> else {
            return
        }
        let noDuplicates = setBuilds.removingDuplicateBuilds()
        if builds.count > noDuplicates.count {
            let difference = builds.count - noDuplicates.count
            LogUtility.updateLogWithEvent(.duplicatesFound(difference))
            removeFromXcodeBuilds(xcodeBuilds)
            addToXcodeBuilds(noDuplicates as NSSet)
        }
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

extension NSManagedObjectContext {
    
    var thread: String {
        return concurrencyType == .mainQueueConcurrencyType ? "Main" : "Private"
    }
    
}

