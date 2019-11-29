//
//  FetchLogUtility.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 11/08/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa

class LogUtility {
    
    // MARK: - Properties
    enum LogEvent: Equatable {
        case appLaunched
        case apiResponseError(String)
        case userIsNil
        case userSuccessfullyAddedToDatabase
        case databasePostLaunchOperationCompleted(Bool)
        case databaseUpdateSucceeded(String?)
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
        case coreDataSaveSucceeded
        case coreDataSaveFailed(String)
        case alreadyFetching
        case logUploaded(Bool)
        case couldNotCreateLicenseVerifier
        
        var isProgressEvent: Bool {
            return self != .appLaunched && self != .fetchComplete
        }
        
    }
    
    static var log: String? {
        return FileManager.stringFromFile(fetchLog)
    }
    
    private static var fetchLog: URL {
        return FileManager.buildBuddyApplicationSupportFolder.appendingPathComponent("fetchLog")
    }

    
    // MARK: - Exposed Methods
    static func updateLogWithEvent(_ event: LogEvent) {
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
    
    static func openLog() {
        NSWorkspace.shared.open(fetchLog)
    }
    
    // MARK: - Private Methods
    private static func eventStringForEvent(_ event: LogEvent) -> String {
        switch event {
        case .appLaunched:
            return "---------App Launched--------- \(Date().description)"
        case .derivedDataIsValid(let bool):
            return bool ? "Derived data is valid" : "Derived data is invalid"
        case .databaseUpdateSucceeded(let message):
            if let message = message {
                return "Database update failed with error: \(message)"
            }
            else {
                return "Database update succeeded"
            }
        case .databasePostLaunchOperationCompleted(let bool):
            return "Database post launch operation result: \(bool)"
        case .needsFetch(let bool):
            return bool ? "Needs fetch" : "No need for fetch"
        case .startingFetch(let hasFetched):
            return hasFetched ? "Starting fetching builds" : "First Fetch Of The Day: \(Date().description)"
        case .apiResponseError(let message):
            return "API Response Error: \(message)"
        case .userSuccessfullyAddedToDatabase:
            return "User successfully added to database"
        case .duplicatesFound(let difference):
            return "\(difference) duplicate build(s) found"
        case .logStoreManifestUpdated(let projectName):
            return "Log Store Manifest has been updated for \(projectName)"
        case .fetchingBuilds(let projectName):
            return "Fetching builds for \(projectName)"
        case .noLogs(let projectName):
            return "\(projectName) has no logs."
        case .newBuild(let date):
            return "New Build -----> \(date.description)"
        case .lastModificationDateUpdated(let projectName):
            return "Last modification date updated for \(projectName)"
        case .mergingProject(let projectName):
            return "Multiple instances of \(projectName) found. Merging"
        case .coreDataSaveFailed(let reason):
            return "Core Data Saved Failed: \(reason)"
        case .coreDataSaveSucceeded:
            return "Core Data Save Succeeded"
        case .alreadyFetching:
            return "Attempted Concurrent Fetch Averted"
        case .logUploaded(let bool):
            return "Uploaded Log -> \(bool)"
        case .fetchComplete:
            return "---------------Fetch Complete----------------"
        case .userIsNil:
            return "User needs to be created"
        case .couldNotCreateLicenseVerifier:
            return "Could not create a License Verifier. Something might be wrong with the public key"
        }
    }
}
