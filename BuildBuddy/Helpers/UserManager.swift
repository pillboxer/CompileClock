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
        let data: UserResponsePayload?
    }
    
    private struct UserResponsePayload: Decodable {
        let idCreated: String
        let numberOfProjects: Int
    }
    
    private struct UserData: Encodable {
        let id: String
        let numberOfProjects: Int
    }
    
    static func startPostLaunchUserFlow() {
        createNewUserIfNecessary()
        guard let user = User.existingUser else {
            fatalError("Could not find user after creating")
        }
        performDatabaseCheckOnUser(user) { (shouldAdd, error) in
            if let error = error {
                LogUtility.updateLogWithEvent(.apiResponseError(error.localizedDescription))
            }
            if shouldAdd {
                addToDatabase(user) { (error) in
                    if let error = error {
                        LogUtility.updateLogWithEvent(.apiResponseError(error.localizedDescription))
                        return
                    }
                    LogUtility.updateLogWithEvent(.userSuccessfullyAddedToDatabase)
                }
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
    
    static func performDatabaseCheckOnUser(_ user: User, completionHandler: @escaping (Bool, UserError?) -> Void) {
        guard let id = user.id?.uuidString else {
            completionHandler(false, .missingUUID)
            return
        }
        API.shared.get(resource: .users, apiVersion: .v1, parameters: ["uuid" : id]) { (data, response, error) in
            
            if let error = error {
                completionHandler(false, .apiError(error))
                return
            }
            
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(UserResponse.self, from: data)
                    if !response.success {
                        completionHandler(false, .responseError(response.statusCode, response.errorMessage))
                        return
                    }
                    // If we return a 404, it means the user needs to be added to the DB
                    completionHandler(response.statusCode == 404, nil)
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
    
    static func addToDatabase(_ user: User, completionHandler: @escaping (UserError?) -> Void) {
        guard let id = user.id?.uuidString else {
            return
        }
        let numberOfProjects = XcodeProjectManager.projectsWithBuilds.count
        let userData = UserData(id: id, numberOfProjects: numberOfProjects)
        let body = try? JSONEncoder().encode(userData)
        
        API.shared.post(resource: .users, apiVersion: .v1, body: body, headers: [.jsonContentType]) { (data, response, error) in
            if let error = error {
                completionHandler(.apiError(error))
                return
            }
            
            if let data = data {
                do {
                    let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                    print(userResponse)
                    if !userResponse.success {
                        completionHandler(.responseError(userResponse.statusCode, userResponse.errorMessage))
                        return
                    }
                    completionHandler(nil)
                }
                catch let error {
                    completionHandler(.decodingError(error))
                }
            }
        }
    }
    
}
