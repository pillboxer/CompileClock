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
    
    // MARK: - Creation
    
    static func createNewUserIfNecessary() {
        if existingUser() == nil {
            let user = User(context: CoreDataManager.moc)
            user.id = UUID()
            CoreDataManager.save()
            UserManager.addToDatabase(user)
        }
    }
    
    static func existingUser(inContext context: NSManagedObjectContext = CoreDataManager.moc) -> User? {
        do {
            let fetchRequest: NSFetchRequest<User> = self.fetchRequest()
            let results = try context.fetch(fetchRequest)
            return results.first
        }
        catch {
            #warning("Log error")
            return nil
        }
    }
}
