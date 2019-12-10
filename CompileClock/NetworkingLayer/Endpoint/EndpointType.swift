//
//  EndpointType.swift
//  CompileClock
//
//  Created by Henry Cooper on 28/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

enum APIVersion: String {
    case v1
}

enum APIResource: String {
    case users
    case projects
    case help
}

/// Contains all the information needed to configure an EndPoint
protocol EndpointType {
    var baseURL: URL { get }
    var path: String { get }
    var version: APIVersion { get }
    var resource: APIResource { get }
    var method: HTTPMethod { get }
    var headers: [PostHeader]? { get }
    var task: HTTPTask { get }
    var requiresUserApiKey: Bool { get }
}

extension EndpointType {
    
    var baseURL: URL {
        var components = URLComponents()
        components.scheme = Environment.isDev ? "http" : "https"
        components.host = Environment.isDev ? "localhost" : "api.compileclock.com"
        return components.url!
    }
    
    var version: APIVersion {
        return .v1
    }
    
    var path: String {
        return [version.rawValue, resource.rawValue].joined(separator: "/")
    }
    
    var headers: [PostHeader]? {
        if requiresUserApiKey {
            if let key = KeychainManager.shared.getData(.apiKey) {
                return [.authorization(key)]
            }
        }
        return nil 
    }
    
    var requiresUserApiKey: Bool {
        return true
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}
