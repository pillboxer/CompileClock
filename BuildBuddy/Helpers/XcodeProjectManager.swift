//
//  MenuHelper.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 04/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class XcodeProjectManager {
    
    // MARK: - Exposed Methods
    static var projects: [XcodeProject] {
        return retrieveProjects()
    }
    
    static var projectsWithBuilds: [XcodeProject] {
        return projects.filter() { $0.builds.count > 0 }
    }
    
    static var earliestBuildDate: Date {
        let dates = projects.map() { $0.earliestBuildDate }
        return dates.sorted() { $0 < $1 }.first ?? Date()
    }
    
    static var needsUpdating: Bool {
        // Filter down the projects so we just get the ones where the plist has been updated
        let projectsWithUpdates = projects.filter() { $0.logStoreHasBeenUpdated == true }
        // True if we have projects with updates
        return !projectsWithUpdates.isEmpty
    }

    static func buildTypeAndSuccessTuple(_ buildKey: String, fromFolder folder: String) -> (type: XcodeBuild.BuildType, success: Bool)? {
        let folderURL = URL(fileURLWithPath: folder)
        let activityLogURL = folderURL.appendingPathComponent("\(buildKey).xcactivitylog")
        let rawLog = try? Data(contentsOf: activityLogURL)
        return ActivityLogManager.buildTypeAndSuccessTuple(fromLog: rawLog)
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
    
    static private var averageBuildTimeForAllProjects: Double {
        let averageBuildTimesForProjects = projects.map() { $0.averageBuildTime }
        let totalAverage = averageBuildTimesForProjects.reduce(0, +)
        return totalAverage / Double(projects.count)
    }
    
    static private func retrieveProjects() -> [XcodeProject] {
        // First, get all the saved projects
        let savedProjects = XcodeProject.fetchAll() ?? []
        let savedProjectNames = savedProjects.compactMap() { $0.folderName }
        // Filter out the saved projects from derivedData
        let newProjectNames = foldersAtDerivedDataLocation.filter() { folderName in
            
            if folderName.contains("ModuleCache") { //|| folderName.contains("BuildBuddy") {
                return false
            }
            return !savedProjectNames.contains(folderName)
        }
        // Create new projects if any
        let newProjects = newProjectNames.compactMap() { XcodeProject.createNewProjectWithFolderName($0) }
        return savedProjects + newProjects
    }
}

extension URL {
    var buildFolder: URL {
        return self.appendingPathComponent("Logs/Build")
    }
    
}
