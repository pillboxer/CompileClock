//
//  XcodeProject+CoreDataProperties.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 12/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//
//

import Foundation
import CoreData


extension XcodeProject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<XcodeProject> {
        return NSFetchRequest<XcodeProject>(entityName: "XcodeProject")
    }

    @NSManaged public var folderName: String?
    @NSManaged public var xcodeBuilds: NSSet?
    @NSManaged public var lastModificationDate: Double

}

// MARK: Generated accessors for xcodeBuilds
extension XcodeProject {

    @objc(addXcodeBuildsObject:)
    @NSManaged public func addToXcodeBuilds(_ value: XcodeBuild)

    @objc(removeXcodeBuildsObject:)
    @NSManaged public func removeFromXcodeBuilds(_ value: XcodeBuild)

    @objc(addXcodeBuilds:)
    @NSManaged public func addToXcodeBuilds(_ values: NSSet)

    @objc(removeXcodeBuilds:)
    @NSManaged public func removeFromXcodeBuilds(_ values: NSSet)

}
