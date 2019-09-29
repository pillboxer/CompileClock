//
//  Endpoints.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 29/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case urlDoesNotExist
    case genericRequestError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The URL Provided was invalid"
        case .urlDoesNotExist:
            return "The URL Does Not Exist On The Server"
        case .genericRequestError(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - USERS

enum UsersEndpoint: EndpointType {
    case add(_ request: UserRequest)
}

struct UserResponse: Decodable {
    let statusCode: Int
    let success: Bool
    let errorMessage: String?
    let data: UserResponsePayload?
    
    struct UserResponsePayload: Decodable {
        let id: String
        let numberOfProjects: Int
    }
}

enum UserError: Error {
    case responseError(Int, String?)
    case missingUUID
    case routerError(Error)
    case decodingError(String)
    case APIError(APIError)
    
    var localizedDescription: String {
        switch self {
        case .responseError(let code, let message):
            return "Returned with code \(code): \(message ?? "No message returned")"
        case .missingUUID:
            return "No UUID Provided"
        case .routerError(let error):
            return "Router error: \(error.localizedDescription)"
        case .decodingError(let message):
            return "Could not decode JSON: \(message)"
        case .APIError(let apiError):
            return apiError.localizedDescription
        }
    }
}

extension UsersEndpoint {
    
    struct UserRequest: Encodable {
        let numberOfProjects: Int
    }
    
    var method: HTTPMethod {
        switch self {
        case .add:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .add(let request):
            return .request(body: request, urlParameters: nil)
        }
    }
    
    var resource: APIResource {
        return .users
    }
    
    var headers: [PostHeader]? {
        return nil
    }
    
}

// MARK: - PROJECTS

struct ProjectsResponse: Decodable {
    let uuid: String
    let userid: String
    let longestBuildTime: Double?
    let averageBuildTime: Double?
}

enum ProjectsEndpoint: EndpointType {
    case add(_ request: ProjectRequest)
}

extension ProjectsEndpoint {
    
    struct ProjectRequest: Encodable {
        let numberOfBuilds: Int
        let longestBuildTime: Double?
        let averageBuildTime: Double?
        let workingTimePercentage: Double?
    }
    
    var resource: APIResource {
        return .projects
    }
    
    var method: HTTPMethod {
        switch self {
        case .add:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .add(let request):
            return .request(body: request, urlParameters: nil)
        }
    }
    
    
    
}
