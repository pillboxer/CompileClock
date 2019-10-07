//
//  API.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 15/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
typealias JSONResponse = [String : Any]

struct APIManager {
    
    static let shared = APIManager()
    
    func addUserToDatabase(projectCount: Int, completion: @escaping (UserResponse?, APIError?) -> Void) {
        let router = Router<UsersEndpoint>()
        let request = UsersEndpoint.UserRequest(numberOfProjects: projectCount)
        let endpoint = UsersEndpoint.add(request)
        router.request(endpoint, decoding: UserResponse.self) { response, error in
            completion(response as? UserResponse, error)
        }
    }
    
    func createOrUpdateDatabaseProjects(_ projects: [XcodeProject], shouldCreate: Bool, completion: @escaping (APIError?) -> Void) {
        
        guard projects.count > 0, let userid = User.existingUser?.uuid else {
            return
        }
        
        let request = ProjectsEndpoint.ProjectsRequest.createProjectRequestFromProjects(projects, id: userid)
        let endpoint = shouldCreate ? ProjectsEndpoint.add(request) : ProjectsEndpoint.update(request)
        let router = Router<ProjectsEndpoint>()
        
        router.request(endpoint, decoding: ProjectsResponse.self) { (response, error) in
            guard let response = response as? ProjectsResponse else {
                completion(error)
                LogUtility.updateLogWithEvent(.projectsAddedToDatabase(false))
                return
            }
            if response.success {
                completion(error)
                XcodeProject.updateProjectsFromResponse(projects: projects, response: response)
            }
            LogUtility.updateLogWithEvent(.projectsAddedToDatabase(response.success))
        }
        
    }
        
}
