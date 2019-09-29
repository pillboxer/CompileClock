//
//  User+CoreDataProperties.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 05/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var uuid: String?

}
