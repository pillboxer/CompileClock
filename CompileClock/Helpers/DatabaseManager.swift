//
//  UserManager.swift
//  CompileClock
//
//  Created by Henry Cooper on 05/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import KeychainAccess
import CoreData
class DatabaseManager {
    
    static let shared = DatabaseManager()
    private var isUpdatingProjects = false
    var payloadCache = [String : ProjectsResponse.ProjectComparisonPayload]()
    
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
    
    func updateProjects(completion: ((APIError?) -> Void)?) {
        let context = CoreDataManager.privateMoc
        
        context.perform {
            
            if self.isUpdatingProjects
                || User.existingUser(context) == nil
                || FetchingMenuItemManager.isFetching {
                completion?(nil)
                return
            }
            self.isUpdatingProjects = true
            
            guard let projects = XcodeProject.existingProjectsWithBuilds(context) else {
                return
            }
            
            APIManager.shared.createOrUpdateDatabaseProjects(projects) {
                (error) in
                LogUtility.updateLogWithEvent(.databaseUpdateSucceeded(error?.localizedDescription))
                self.clearCache()
                self.isUpdatingProjects = false
                completion?(error)
            }
        }
    }
    
    private func clearCache() {
        payloadCache.removeAll()
    }
    
    func compareProject(_ uuid: String, completion: @escaping (ProjectsResponse.ProjectComparisonPayload?, APIError?) -> Void) {
        if let payload = payloadCache[uuid] {
            completion(payload, nil)
            return
        }
        
        APIManager.shared.compareProject(uuid: uuid) { (payload, error) in
            if let error = error {
                LogUtility.updateLogWithEvent(.apiResponseError(error.localizedDescription))
                completion(nil, error)
            }
            else if let payload = payload {
                self.payloadCache[uuid] = payload
                completion(payload, nil)
            }
            else {
                completion(nil, nil)
            }
        }
    }
    
    private func createNewUserIfNecessary(completion: @escaping (APIError?) -> Void) {
        
        let projectCount = XcodeProjectManager.projectsWithBuilds.count
        let uuid = User.existingUser()?.uuid
        
        APIManager.shared.addOrUpdateUserInDatabase(uuid: uuid, projectCount: projectCount) { (response, error) in
            if let error = error {
                completion(error)
                LogUtility.updateLogWithEvent(.apiResponseError(error.localizedDescription))
                return
            }
            else if let id = response?.data?.id,
                let apiKey = response?.data?.apiKey {
                let context = CoreDataManager.privateMoc

                context.perform {
                    if let user = User.existingUser(context) {
                        user.uuid = id
                    }
                    else {
                        let newUser = User(context: context)
                        newUser.uuid = id
                    }
                    context.saveWithTry()
                }
                
                KeychainManager.shared.storeData(.apiKey, value: apiKey)
                LogUtility.updateLogWithEvent(.userSuccessfullyAddedToDatabase)
                completion(nil)
            }
            else {
                completion(nil)
            }
        }
    }
    
}
