//
//  UserManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 05/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import KeychainAccess

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
        if isUpdatingProjects || User.existingUser == nil {
            return
        }
        isUpdatingProjects = true
        let projects = XcodeProjectManager.projectsWithBuilds
        
        APIManager.shared.createOrUpdateDatabaseProjects(projects) {
            (error) in
            LogUtility.updateLogWithEvent(.databaseUpdateSucceeded(error?.localizedDescription))
            self.clearCache()
            self.isUpdatingProjects = false
            completion?(error)
        }
    }
    
    private func clearCache() {
        payloadCache.removeAll()
    }
    
    func compareProject(_ uuid: String, completion: @escaping (ProjectsResponse.ProjectComparisonPayload?) -> Void) {
        if let payload = payloadCache[uuid] {
            completion(payload)
            return
        }
        
        APIManager.shared.compareProject(uuid: uuid) { (payload, error) in
            if let error = error {
                LogUtility.updateLogWithEvent(.apiResponseError(error.localizedDescription))
                completion(nil)
            }
            else if let payload = payload {
                self.payloadCache[uuid] = payload
                completion(payload)
            }
            else {
                completion(nil)
            }
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
                    guard let id = response?.data?.id, let apiKey = response?.data?.apiKey else {
                        completion(.missingIntegralData)
                        return
                    }
                    newUser.uuid = id
                    KeychainManager.shared.storeData(.apiKey, value: apiKey)
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
