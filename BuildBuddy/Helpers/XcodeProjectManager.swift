//
//  MenuHelper.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 04/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import CoreData

class XcodeProjectManager {
    
    // MARK: - Exposed Methods
    static var projects: [XcodeProject] = []
    
    static var projectsWithBuilds: [XcodeProject] {
        let projectsWithBuilds = projects.filter() { $0.builds.count > 0 }
        return projectsWithBuilds
    }
    
    static var visibleProjects: [XcodeProject] {
        return projectsWithBuilds.filter() { $0.isVisible }
    }
    
    static var hasBuiltToday: Bool {
        return totalBuildsToday > 0
    }
    
    static var earliestBuildDate: Date {
        let dates = projects.map() { $0.earliestBuildDate }
        return dates.sorted() { $0 < $1 }.first ?? Date()
    }
    
    static private var averageTimeToday: Double {
        let projectsWithBuildsToday = projects.filter() { $0.todaysBuilds.count > 0 }
        let count = Double(projectsWithBuildsToday.count)
        guard count > 0 else {
            return 0
        }
        let todaysBuilds = projectsWithBuildsToday.flatMap() { $0.todaysBuilds }
        let projectTotals = todaysBuilds.map() { $0.totalBuildTime }
        let totalTime = projectTotals.reduce(0, +)
        return totalTime / Double(projectTotals.count)
    }
    
    static private var lastBuildTime: Double {
        let lastBuilds = projects.compactMap() { $0.lastBuild }
        let latestBuild =  lastBuilds.sorted() { $0.buildDate > $1.buildDate }.first
        guard let latest = latestBuild else {
            return 0
        }
        return latest.totalBuildTime
    }
    
    static private var totalBuildsToday: Int {
        let builds = projects.flatMap() { $0.todaysBuilds }
        return builds.count
    }
    
    static private var allTimeBuildCount: Int {
        let countArray = projects.map() { $0.builds.count }
        return countArray.reduce(0, +)
    }
    
    static private var allTimeDuration: Double {
        let totalTimes = projects.map() { $0.totalBuildTime }
        return totalTimes.reduce(0, +)
    }
    
    static private var averageTimeTodayString: String {
        return String.prettyTime(averageTimeToday)
    }
    
    static private var lastBuildTimeString: String {
        return String.prettyTime(lastBuildTime)
    }
    
    static private var totalTimeTodayString: String {
        let buildTimes = projects.map() { $0.todaysBuildTime }
        let total = buildTimes.reduce(0, +)
        return String.prettyTime(total)
    }
    
    static private var allTimeDurationString: String {
        return String.prettyTime(allTimeDuration)
    }
    
    static var needsUpdating: Bool {
        if forceUpdate {
            forceUpdate = false
            return true
        }
        // Filter down the projects so we just get the ones where the plist has been updated
        let projectsWithUpdates = projects.filter() { $0.logStoreHasBeenUpdated == true }
        // True if we have projects with updates
        return !projectsWithUpdates.isEmpty
    }
    
    static func forceProjectUpdate() {
        forceUpdate = true
    }
    
    static var displayText: String {
        switch UserDefaults.displayTextOption {
        case .builds:
            return " \(XcodeProjectManager.totalBuildsToday)"
        case .time:
            return " \(XcodeProjectManager.totalTimeTodayString)"
        case .average:
            return " \(XcodeProjectManager.averageTimeTodayString)"
        case .last :
            return " \(XcodeProjectManager.lastBuildTimeString)"
        case .allTimeCount:
            return " \(XcodeProjectManager.allTimeBuildCount)"
        case .allTimeDuration:
            return " \(XcodeProjectManager.allTimeDurationString)"
        }
    }
    
    static func fetchBuilds() {
        // This should always be called on a background thread
        let context = CoreDataManager.privateMoc
        context.performAndWait {
            if let projects = XcodeProject.existingObjects(withPredicate: nil, sortDescriptors: nil, inContext: context) as? [XcodeProject] {
                for project in projects {
                    if project.logStoreHasBeenUpdated {
                        project.fetchBuilds()
                    }
                }
            }
            context.saveWithTry()
        }
    }
    
    static func checkAndRemoveDuplicates() {
        projects.forEach() { $0.checkAndRemoveDuplicates() }
    }
    
    static func retrieveNewProjects() {
        // First, get all the saved projects
        let savedProjects = XcodeProject.fetchAll() ?? []
        let savedProjectNames = Set(savedProjects.compactMap() { $0.folderName })
        // Filter out the saved projects from derivedData
        let newProjectNames = foldersAtDerivedDataLocation.filter() { folderName in
            return !savedProjectNames.contains(folderName)
        }
        // Create new projects if any
        let newProjects = newProjectNames.compactMap() { XcodeProject.createNewProjectWithFolderName($0) }
        projects = savedProjects + newProjects
    }
    
    static func start() {
        retrieveNewProjects()
        checkAndRemoveDuplicates()
        mergeProjectsIfNecessary()
    }
    
    static func buildTypeAndSuccessTuple(_ buildKey: String, fromFolder folder: String) -> (type: XcodeBuild.BuildType, success: Bool)? {
        let folderURL = URL(fileURLWithPath: folder)
        let activityLogURL = folderURL.appendingPathComponent("\(buildKey).xcactivitylog")
        let rawLog = try? Data(contentsOf: activityLogURL)
        return ActivityLogManager.buildTypeAndSuccessTuple(fromLog: rawLog)
    }
    
    static func mergeProjectsIfNecessary() {
        
        let context = CoreDataManager.privateMoc
        
        context.perform {
            let projectsToCheck: [XcodeProject] = projects.compactMap() {
                if let project = context.object(with: $0.objectID) as? XcodeProject {
                    return project
                }
                return nil
            }
            
            let projectNames: [String?] = projectsToCheck.map() { $0.name }
            let occurences = projectNames.map() { ($0, 1) }
            let dict = Dictionary(occurences, uniquingKeysWith: +)
            let moreThanOne = dict.filter() { $0.value > 1 }
            
            let filtered = projectsToCheck.filter() { project in
                for (key, _) in moreThanOne {
                    if key == project.name && project.builds.count > 0 {
                        return true
                    }
                }
                return false
            }
            var sortedByModificationDate = filtered.sorted() { $0.lastModificationDate < $1.lastModificationDate }
            if let newest = sortedByModificationDate.last {
                LogUtility.updateLogWithEvent(.mergingProject(newest.name))
                while sortedByModificationDate.count > 1 {
                    let currentOldest = sortedByModificationDate.removeFirst()
                    for build in currentOldest.builds {
                        newest.addToXcodeBuilds(build)
                    }
                    if let folderName = currentOldest.folderName {
                        XcodeProject.deleteProjectWithFolderName(folderName)
                    }
                }
            }
        }
        
        
    }
    
    // MARK: - Private Methods
    static private var foldersAtDerivedDataLocation: [String] {
        let fileManager = FileManager.default
        guard let location = UserDefaults.derivedDataURL else {
            return []
        }
        
        guard let enumerator = fileManager.enumerator(at: location, includingPropertiesForKeys: [.nameKey, .isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants], errorHandler: nil) else {
            return []
        }
        
        return enumerator.map() { ($0 as! URL).buildFolder.path }
    }
    
    
    static private var forceUpdate = false
}

extension URL {
    var buildFolder: URL {
        return self.appendingPathComponent("Logs/Build")
    }
    
}
