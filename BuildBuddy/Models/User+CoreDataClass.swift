//
//  User+CoreDataClass.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 05/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    
    static var existingUser: User? {
        do {
            let fetchRequest: NSFetchRequest<User> = self.fetchRequest()
            let results = try CoreDataManager.moc.fetch(fetchRequest)
            return results.first
        }
        catch {
            return nil
        }
    }
}
