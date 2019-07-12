//
//  MenuHelper.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 04/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class XcodeProjectManager {
    
    static var projects: [XcodeProject] = {
        return retrieveProjects()
    }()
    
    static var earliestBuildDate: Date {
        let dates = projects.map() { $0.earliestBuildDate }
        return dates.sorted() { $0 < $1 }.first ?? Date()
    }
    
    private static func retrieveProjects() -> [XcodeProject] {
        
        // First, get all the saved projects
        let savedProjects = XcodeProject.fetchAll() ?? []
        let savedProjectNames = savedProjects.compactMap() { $0.folderName }
        // Filter out the saved projects from derivedData
        let newProjectNames = foldersAtDerivedDataLocation.filter() { folderName in
            
            // Dont need this here
            
            if folderName.contains("ModuleCache") {
                return false
            }
            return !savedProjectNames.contains(folderName)
        }
        
        // Create new projects if any
        let newProjects = newProjectNames.compactMap() { XcodeProject.createNewProjectWithFolderName($0) }
        return savedProjects + newProjects
    }
    
    static func buildTypeAndSuccessTuple(_ buildKey: String, fromFolder folder: String) -> (type: XcodeBuild.BuildType, success: Bool) {
        let folderURL = URL(fileURLWithPath: folder)
        let activityLogURL = folderURL.appendingPathComponent("\(buildKey).xcactivitylog")
        let rawLog = try? Data(contentsOf: activityLogURL)
        return ActivityLogManager.buildTypeAndSuccessTuple(fromLog: rawLog)
    }
    
    private static var foldersAtDerivedDataLocation: [String] {
        #warning("What if user has different derived data location")
        let fileManager = FileManager.default
        guard let libraryFolder = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            return []
        }
        let derivedDataLocation = URL(fileURLWithPath: "\(libraryFolder)/Developer/Xcode/DerivedData")
        guard let enumerator = fileManager.enumerator(at: derivedDataLocation, includingPropertiesForKeys: [.nameKey, .isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants], errorHandler: nil) else {
            return []
        }
        
        // Get the build folder here
    
        return enumerator.map() { url in
            print(url)
            return (url as! URL).buildFolder.path
            
        }
    }
    
}

extension URL {
    
    var buildFolder: URL {
        return self.appendingPathComponent("Logs/Build")
    }
    
}
