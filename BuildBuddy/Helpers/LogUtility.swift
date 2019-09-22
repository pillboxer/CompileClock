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
    enum LogUploadError: Error {
        case tooManyRequests
        case logNotFound
        case urlInvalid
        case uploadError(String)
        
        var description: String {
            switch self {
            case .logNotFound:
                return "Could not find log"
            case .tooManyRequests:
                return "Too many requests, please try again later"
            case .uploadError(let error):
                return "Something went wrong uploading: \(error)"
            case .urlInvalid:
                return "URL was invalid"
            }
        }
    }
        
    enum LogEvent: Equatable {
        case appLaunched
        case apiResponseError(String)
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
        case logUploaded
        var isProgressEvent: Bool {
            return self != .appLaunched && self != .fetchComplete
        }
        
    }
    
    private static var logController: UploadLogWindowController?
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
    
    static func showUploadLogController() {
        logController = UploadLogWindowController()
        logController?.showWindow(nil)
    }
    
    static func uploadLog(withEmail email: String, completion: @escaping (LogUploadError?) -> Void) {
        
        #warning("Upload log start again")
    }
    
    static var log: String? {
        return FileManager.stringFromFile(fetchLog)
    }
    
    // MARK: - Private Methods
    private static func eventStringForEvent(_ event: LogEvent) -> String {
        switch event {
        case .appLaunched:
            return "---------App Launched--------- \(Date().description)"
        case .derivedDataIsValid(let bool):
            return bool ? "Derived data is valid" : "Derived data is invalid"
        case .needsFetch(let bool):
            return bool ? "Needs fetch" : "No need for fetch"
        case .startingFetch(let hasFetched):
            return hasFetched ? "Starting fetching builds" : "First Fetch Of The Day: \(Date().description)"
        case .apiResponseError(let message):
            return "API Response Error: \(message)"
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
        case .alreadyFetching:
            return "Attempted Concurrent Fetch Averted"
        case .logUploaded:
            return "Uploaded Log"
        case .fetchComplete:
            return "---------------Fetch Complete----------------"
        }
    }
    

    
}
