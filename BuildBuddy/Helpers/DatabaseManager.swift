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
                self.updateProjects { (error) in
                    completion(error == nil)
                }
            }
            else {
                completion(false)
            }
        }
    }
    
    private func updateProjects(completion: @escaping (APIError?) -> Void) {
        
        let projectsToInsert = XcodeProjectManager.projectsWithBuilds.filter() { $0.uuid == nil }
        let projectsToUpdate = XcodeProjectManager.projectsWithBuilds.filter() { $0.uuid != nil }
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        var lastError: APIError?
        
        APIManager.shared.createOrUpdateDatabaseProjects(projectsToInsert, shouldCreate: true) { (error) in
            lastError = error
            dispatchGroup.leave()
        }
        APIManager.shared.createOrUpdateDatabaseProjects(projectsToUpdate, shouldCreate: false) { (error) in
            lastError = error
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(lastError)
        }
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
