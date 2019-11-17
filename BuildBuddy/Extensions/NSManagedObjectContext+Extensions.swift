//
//  NSManagedObjectContext+Extensions.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 17/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func saveWithTry() {
        do {
            try save()
        }
        catch let error {
            print("CORE DATA SAVE ERROR: \(error.localizedDescription)")
        }
    }
    
}
