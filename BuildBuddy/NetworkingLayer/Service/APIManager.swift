//
//  API.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 15/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import CoreData
typealias JSONResponse = [String : Any]

struct APIManager {
    
    static let shared = APIManager()
    
    func addOrUpdateUserInDatabase(uuid: String?, projectCount: Int, completion: @escaping (UserResponse?, APIError?) -> Void) {
        let router = Router<UsersEndpoint>()
        let request = UsersEndpoint.UserRequest(uuid: uuid, numberOfProjects: projectCount)
        let endpoint = UsersEndpoint.add(request) 
        router.request(endpoint, decoding: UserResponse.self) { response, error in
            completion(response as? UserResponse, error)
        }
    }
    
    func createOrUpdateDatabaseProjects(_ projects: [XcodeProject], completion: @escaping (APIError?) -> Void) {
        let context = CoreDataManager.privateMoc
        
        guard let userid = User.existingUser(context)?.uuid else {
            completion(.missingUserID)
            return
        }
        
        guard projects.count > 0 else {
            completion(nil)
            return
        }
        
        
        let request = ProjectsEndpoint.ProjectsRequest.createProjectRequestFromProjects(projects, id: userid)
        let endpoint = ProjectsEndpoint.add(request)
        let router = Router<ProjectsEndpoint>()
        let projectNames = projects.compactMap() { $0.folderName }
        router.request(endpoint, decoding: ProjectsResponse.self) { (response, error) in
            guard let response = response as? ProjectsResponse else {
                completion(error)
                return
            }

            var threadSafeProjects = [XcodeProject]()
            for name in projectNames {
                context.performAndWait {
                    if let project = XcodeProject.existingProjectWithFolderName(name, on: context) {
                        threadSafeProjects.append(project)
                    }
                    XcodeProject.updateProjectsFromResponse(projects: threadSafeProjects, response: response)
                    context.saveWithTry()
                }

            }
            completion(error)
        }
    }
    
    func compareProject(uuid: String, completion: @escaping (ProjectsResponse.ProjectComparisonPayload?, APIError?) -> Void) {
        let endpoint = ProjectsEndpoint.compareAverage(uuid)
        let router = Router<ProjectsEndpoint>()
        
        router.request(endpoint, decoding: ProjectsResponse.self) { (response, error) in
            guard let response = response as? ProjectsResponse else {
                completion(nil, error)
                return
            }
            
            if let payload = response.comparisonPayload {
                completion(payload, nil)
                return
            }
        }
    }
    
    func uploadLog(_ log: String, withEmail email: String, completion: @escaping (LogResponse?, APIError?) -> Void) {
        
        guard let userid = User.existingUser()?.uuid else {
            LogUtility.updateLogWithEvent(.logUploaded(false))
            return
        }
        let request = LogRequest(logText: log, email: email, userid: userid)
        let endpoint = LogEndpoint.upload(request)
        let router = Router<LogEndpoint>()
        
        router.request(endpoint, decoding: LogResponse.self) { (response, error) in
            completion(response as? LogResponse, error)
        }
    }
}
