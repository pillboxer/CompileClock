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
    case routerError(Error)
    case decodingError(String)
    case responseError(Int, String?)
    case missingUserID
    
    var localizedDescription: String {
        switch self {
        case .responseError(let code, let message):
            return "Returned with code \(code): \(message ?? "No message returned")"
        case .invalidURL:
            return "The URL Provided was invalid"
        case .urlDoesNotExist:
            return "The URL Does Not Exist On The Server"
        case .routerError(let error):
            return "Router error: \(error.localizedDescription)"
        case .decodingError(let message):
            return "Could not decode JSON: \(message)"
        case .missingUserID:
            return "Could not find a userid"
        }
    }
}

protocol APIResponse: Decodable {
    var statusCode: Int { get }
    var success: Bool { get }
    var errorMessage: String? { get }
}

// MARK: - USERS

enum UsersEndpoint: EndpointType {
    case add(_ request: UserRequest)
}

struct UserResponse: APIResponse {
    let statusCode: Int
    let success: Bool
    let errorMessage: String?
    let data: UserResponsePayload?
    
    struct UserResponsePayload: Decodable {
        let id: String
        let numberOfProjects: Int
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

struct ProjectsResponse: APIResponse {
    let statusCode: Int
    let success: Bool
    let errorMessage: String?
    let data: [ProjectsResponsePayload]?
    let comparisonPayload: ProjectComparisonPayload?
    
    struct ProjectsResponsePayload: Decodable {
        let uuid: String
        let userid: String
        let numberOfBuilds: Int
        let longestBuildTime: Double?
        let averageBuildTime: Double?
        let workingTimePercentage: Double?
    }
    
    struct ProjectComparisonPayload: Decodable {
        let averageBuildTime: Double?
        let longestBuildTime: Double?
        let workingTimePercentage: Double?
        let averageBuildsPerDay: Double?
        let mostBuilds: Double?
        
        enum CodingKeys: String, CodingKey {
            case averageBuildTime = "average_build_time"
            case longestBuildTime = "longest_build_time"
            case workingTimePercentage = "working_time_percentage"
            case averageBuildsPerDay = "average_builds"
            case mostBuilds = "most_builds"
        }
    }
}

enum ProjectsEndpoint: EndpointType {
    case add(_ request: ProjectsRequest)
    case compareAverage(_ uuid: String)
}


extension ProjectsEndpoint {
    
    struct ProjectsRequest: Encodable {
        let projects: [ProjectRequest]
        
        static func createProjectRequestFromProjects(_ projects: [XcodeProject], id: String) -> ProjectsRequest {
            let projects = projects.map { project -> ProjectRequest in
                return ProjectRequest(userid: id,
                                      uuid: project.uuid,
                                      numberOfBuilds: project.totalNumberOfBuilds,
                                      longestBuildTime: project.longestBuildTime,
                                      averageBuildTime: project.averageBuildTime,
                                      workingTimePercentage: project.percentageOfWorkingTimeSpentBuilding,
                                      averageBuilds: project.dailyAverageNumberOfBuilds, mostBuilds: project.mostBuildsInADay?.recurrances
                                      )
            }
            return ProjectsRequest(projects: projects)
        }
    }
    
    struct ProjectRequest: Encodable {
        let userid: String
        let uuid: String?
        let numberOfBuilds: Int
        let longestBuildTime: Double?
        let averageBuildTime: Double?
        let workingTimePercentage: Double?
        let averageBuilds: Double?
        let mostBuilds: Int?
    }
    
    var resource: APIResource {
        return .projects
    }
    
    var method: HTTPMethod {
        switch self {
        case .add:
            return .post
        case .compareAverage:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .add(let request):
            return .request(body: request, urlParameters: nil)
        case .compareAverage(let uuid):
            let params = ["compareid": uuid]
            return .request(body: nil, urlParameters: params)
        }
    }

    
    
    
}
