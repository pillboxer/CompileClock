//
//  XcodeBuild+CoreDataClass.swift
//  BuildTimes
//
//  Created by Henry Cooper on 07/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//
//

import Foundation
import CoreData


@objcMembers
@objc(XcodeBuild)
public class XcodeBuild: NSManagedObject {
    
    private static let timeStartedRecording = "timeStartedRecording"
    private static let timeStoppedRecording = "timeStoppedRecording"
    private static let schemeName = "schemeIdentifier-schemeName"
    
    convenience init?(_ dict: [String: Any]) {
        guard let started = dict[XcodeBuild.timeStartedRecording] as? Double,
            let stopped = dict[XcodeBuild.timeStoppedRecording] as? Double,
            let name = dict[XcodeBuild.schemeName] as? String else {
                return nil
        }
        let moc = CoreDataManager.moc
        let entity = NSEntityDescription.entity(forEntityName: "XcodeBuild", in: moc)!
        self.init(entity: entity, insertInto: moc)
        self.name = name
        self.timeStarted = started
        self.timeStopped = stopped
    }
    
    enum BuildType: Int {
        case run
        case archive
        case test
        case clean
        
        var pretty: String {
            switch self.rawValue {
            case 1:
                return "Archive"
            case 2:
                return "Test"
            case 3:
                return "Clean"
            default:
                return "Run"
            }
        }
    }
    
    var buildType: BuildType {
        get {
            let int = type?.intValue ?? 0
            return BuildType(rawValue: int) ?? .run
        }
        set {
            type = NSNumber(integerLiteral: newValue.rawValue)
        }
    }
    
    var buildDate: Date {
        return Date(timeIntervalSinceReferenceDate: timeStarted)
    }
    
    var totalBuildTime: Double {
        return timeStopped - timeStarted
    }
    
    var buildDateIsToday: Bool {
        return Calendar.current.isDate(buildDate, equalTo: Date(), toGranularity: .day)
    }
    
    var buildDateIsInLastWeek: Bool {
        return Calendar.current.isDate(buildDate, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
}
