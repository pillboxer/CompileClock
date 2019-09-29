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
    
    func addUserToDatabase(projectCount: Int, completion: @escaping (UserError?, UserResponse?) -> Void) {
        let router = Router<UsersEndpoint>()
        let request = UsersEndpoint.UserRequest(numberOfProjects: projectCount)
        let endpoint = UsersEndpoint.add(request)
        router.request(endpoint) { (data, response, error) in
            if let error = error {
                completion(.routerError(error), nil)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 404 {
                    completion(.APIError(.urlDoesNotExist), nil)
                    return
                }
            }
            
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(UserResponse.self, from: data)
                    if !response.success {
                        completion(.responseError(response.statusCode, response.errorMessage), nil)
                        return
                    }
                    completion(nil, response)
                }
                catch let error {
                    completion(.decodingError(error.localizedDescription), nil)
                }
            }
        }
    }
    
}
