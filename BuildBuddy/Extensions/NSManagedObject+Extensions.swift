//
//  NSManagedObject+Extensions.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 12/10/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    class func existingObject(withPredicate predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, inContext context: NSManagedObjectContext?) -> Any? {
        return existingObjects(withPredicate: predicate, sortDescriptors: sortDescriptors, inContext: context)?.first
    }
    
    public class func existingObjects(withPredicate predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, inContext context: NSManagedObjectContext?) -> [Any]? {
        let moc = context ?? CoreDataManager.moc
        if let entityName = entity().name {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            do {
                let result = try moc.fetch(request)
                return result
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
