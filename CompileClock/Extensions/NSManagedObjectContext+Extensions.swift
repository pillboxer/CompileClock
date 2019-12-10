//
//  NSManagedObjectContext+Extensions.swift
//  CompileClock
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
            LogUtility.updateLogWithEvent(.coreDataSaveSucceeded)
        }
        catch let error {
            LogUtility.updateLogWithEvent(.coreDataSaveFailed(error.localizedDescription))
        }
    }
    
}
