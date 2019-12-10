//
//  XcodeBuild+CoreDataProperties.swift
//  CompileClock
//
//  Created by Henry Cooper on 12/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//
//

import Foundation
import CoreData


extension XcodeBuild {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<XcodeBuild> {
        return NSFetchRequest<XcodeBuild>(entityName: "XcodeBuild")
    }

    @NSManaged public var name: String?
    @NSManaged public var timeStarted: Double
    @NSManaged public var buildKey: String?
    @NSManaged public var timeStopped: Double
    @NSManaged public var type: NSNumber?
    @NSManaged public var wasSuccessful: Bool
    @NSManaged public var xcodeProject: XcodeProject?

}
