//
//  UserManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 05/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class UserManager {
    
    enum UserError: Error {
        case responseError(Int, String?)
        case missingUUID
        case decodingError(Error)
        case apiError(API.APIError)
        
        var localizedDescription: String {
            switch self {
            case .responseError(let code, let message):
                return "Returned with code \(code). Error: \(message ?? "No message returned")"
            case .missingUUID:
                return "No UUID Provided"
            case .apiError(let error):
                return error.localizedDescription
            case .decodingError(let error):
                return error.localizedDescription
            }
        }
    }
    
    private struct UserResponse: Decodable {
        let statusCode: Int
        let success: Bool
        let errorMessage: String?
    }
    
    static func startPostLaunchUserFlow() {
        createNewUserIfNecessary()
        guard let user = User.existingUser else {
            fatalError("Could not find user after creating")
        }
        addUserToDatabaseIfNecessary(user) { (shouldAdd, error) in
            if let error = error {
                LogUtility.updateLogWithEvent(.apiResponseError(error.localizedDescription))
            }
            if shouldAdd {
                print("Should add")
            }
        }
    }
    
    static func createNewUserIfNecessary() {
        guard let _ = User.existingUser else {
            let user = User(context: CoreDataManager.moc)
            user.id = UUID()
            CoreDataManager.save()
            return
        }
    }
    
    static func addUserToDatabaseIfNecessary(_ user: User, completionHandler: @escaping (Bool, UserError?) -> Void) {
        guard let id = user.id?.uuidString else {
            completionHandler(false, .missingUUID)
            return
        }
        API.get(resource: .users, apiVersion: .v1, parameters: ["uuid" : id]) { (data, response, error) in
            
            if let error = error {
                completionHandler(false, .apiError(error))
                return
            }
            
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(UserResponse.self, from: data)
                    if !response.success {
                        completionHandler(false, .responseError(response.statusCode, response.errorMessage))
                    }
                    else {
                        // If we return a 404, it means the user needs to be added to the DB
                        completionHandler(response.statusCode == 404, nil)
                    }
                }
                catch let error {
                    if response?.statusCode == 404 {
                        completionHandler(false, .apiError(.urlDoesNotExit))
                    }
                    completionHandler(false, .decodingError(error))
                }
            }
            
        }
    }
    
    static func addToDatabase(_ user: User) {
        print("POSTING NOW")
    }
    
}
