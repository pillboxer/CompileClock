//
//  FetchLogUtility.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 11/08/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class FetchLogUtility {
    
    private static var fetchLog: URL {
        return FileManager.buildBuddyApplicationSupportFolder.appendingPathComponent("fetchLog")
    }
    
    enum FetchLogEvent: Equatable {
        case appLaunched
        case derivedDataIsValid(Bool)
        case duplicatesFound(Int)
        case needsFetch(Bool)
        case startingFetch(Bool)
        case logStoreManifestUpdated(String)
        case fetchingBuilds(String)
        case noLogs(String)
        case newBuild(Date)
        case lastModificationDateUpdated(String)
        case fetchComplete
        case mergingProject(String)
        case coreDataSaveFailed(String)
        case alreadyFetching
        var isProgressEvent: Bool {
            return self != .appLaunched && self != .fetchComplete
        }
        
    }
    
    
    static func updateLogWithEvent(_ event: FetchLogEvent) {
        var eventString = eventStringForEvent(event)

        if event.isProgressEvent {
            eventString.insert("•", at: eventString.startIndex)
            eventString.insert(" ", at: eventString.index(after: eventString.startIndex))
        }
        
        eventString.insert("\n", at: eventString.endIndex)
        
        if !event.isProgressEvent {
            eventString.insert("\n", at: eventString.endIndex)
        }
        FileManager.updateFile(fetchLog, withText: eventString)
    }
    
    private static func eventStringForEvent(_ event: FetchLogEvent) -> String {
        switch event {
        case .appLaunched:
            return "---------App Launched--------- \(Date().description)"
        case .derivedDataIsValid(let bool):
            return bool ? "Derived data is valid" : "Derived data is invalid"
        case .needsFetch(let bool):
            return bool ? "Needs fetch" : "No need for fetch"
        case .startingFetch(let hasFetched):
            return hasFetched ? "Starting fetching builds" : "First Fetch Of The Day: \(Date().description)"
        case .duplicatesFound(let difference):
            return "\(difference) duplicate build(s) found"
        case .logStoreManifestUpdated(let projectName):
            return "Log Store Manifest has been updated for \(projectName)"
        case .fetchingBuilds(let projectName):
            return "Fetching builds for \(projectName)"
        case .noLogs(let projectName):
            return "\(projectName) has no logs. Deleting project"
        case .newBuild(let date):
            return "New Build -----> \(date.description)"
        case .lastModificationDateUpdated(let projectName):
            return "Last modification date updated for \(projectName)"
        case .mergingProject(let projectName):
            return "Multiple instances of \(projectName) found. Merging"
        case .coreDataSaveFailed(let reason):
            return "Core Data Saved Failed: \(reason)"
        case .alreadyFetching:
            return "Attempted Concurrent Fetch Averted"
        case .fetchComplete:
            return "---------------Fetch Complete----------------"
        }
    }
    
    static func openLog() {
        NSWorkspace.shared.open(fetchLog)
    }
    
}
