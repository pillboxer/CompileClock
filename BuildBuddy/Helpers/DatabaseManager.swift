//
//  UserManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 05/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    func startPostLaunchUserFlow(completion: @escaping (Bool) -> Void) {
        createNewUserIfNecessary { (error) in
            if error == nil {
                self.updateProjects { (success) in
                    completion(success)
                }
            }
            else {
                completion(false)
            }
        }
    }
    
    private func updateProjects(completion: @escaping (Bool) -> Void) {
        let projectsToInsert = XcodeProjectManager.projectsWithBuilds.filter() { $0.uuid == nil }
        let projectsToUpdate = XcodeProjectManager.projectsWithBuilds.filter() { $0.uuid != nil }
        APIManager.shared.createOrUpdateDatabaseProjects(projectsToInsert, shouldCreate: true, completion: completion)
        APIManager.shared.createOrUpdateDatabaseProjects(projectsToUpdate, shouldCreate: false, completion: completion)
    }
    
    private func createNewUserIfNecessary(completion: @escaping (APIError?) -> Void) {
        let projectCount = XcodeProjectManager.projectsWithBuilds.count
        
        if User.existingUser == nil {
            
            APIManager.shared.addUserToDatabase(projectCount: projectCount) { (response, error) in
                if let error = error {
                    completion(error)
                    LogUtility.updateLogWithEvent(.apiResponseError(error.localizedDescription))
                }
                else {
                    let newUser = User(context: CoreDataManager.moc)
                    guard let id = response?.data?.id else {
                        fatalError("Somehow have not received id back")
                    }
                    newUser.uuid = id
                    CoreDataManager.save()
                    LogUtility.updateLogWithEvent(.userSuccessfullyAddedToDatabase)
                    completion(nil)
                }
            }
        }
        else {
            completion(nil)
        }
    }
    
}
