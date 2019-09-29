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
    
    func startPostLaunchUserFlow() {
        createNewUserIfNecessary { (error) in
            #error("YOU ARE HERE!")
            if error == nil {
                print(User.existingUser?.uuid)
            }
            else {
                print(error?.localizedDescription)
            }
        }
    }
    
    private func createNewUserIfNecessary(completion: @escaping (UserError?) -> Void) {
        let projectCount = XcodeProjectManager.projectsWithBuilds.count
        
        if User.existingUser == nil {
            
            APIManager.shared.addUserToDatabase(projectCount: projectCount) { (error, response) in
                if let error = error {
                    completion(error)
                    LogUtility.updateLogWithEvent(.apiResponseError(error.localizedDescription))
                }
                else {
                    let newUser = User(context: CoreDataManager.moc)
                    newUser.uuid = response?.data?.id
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
