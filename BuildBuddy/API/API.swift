//
//  API.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 15/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
typealias JSONResponse = [String : Any]

class API {
    
    static let shared = API()
    
    enum APIError: Error {
        case invalidURL
        case urlDoesNotExit
        case genericRequestError(Error)
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "The URL Provided was invalid"
            case .urlDoesNotExit:
                return "The URL Does Not Exist On The Server"
            case .genericRequestError(let error):
                return error.localizedDescription
            }
        }
    }
    
    struct Endpoint {
        let version: APIVersion
        let resource: APIResource
        let parameters: [String : Any]?
        
        private var path: String {
            return "/" + [version.rawValue, resource.rawValue].joined(separator: "/")
        }
        
        private var queryItems: [URLQueryItem]? {
            let items: [URLQueryItem]? = parameters?.compactMap() {
                if let valueString = $0.value as? String {
                    return URLQueryItem(name: $0.key, value: valueString)
                }
                return nil
            }
            return items
        }
        
        var url: URL? {
            var components = URLComponents()
            components.scheme = "http"
            components.host = "freddybean.compileclock.com"
            components.path = path
            components.queryItems = queryItems
            return components.url
        }
    }
    
    enum APIVersion: String {
        case v1
    }
    
    enum APIResource: String {
        case users
    }
    
    func get(resource: APIResource, apiVersion: APIVersion, parameters: [String : Any], completionHandler: @escaping (Data?, HTTPURLResponse?, APIError?) -> Void) {
        let endpoint = Endpoint(version: apiVersion, resource: resource, parameters: parameters)
        guard let url = endpoint.url else {
            completionHandler(nil, nil, .invalidURL)
            return
        }
        let networkManager = NetworkManager.shared
        networkManager.makeRequest(type: .get, to: url) { (data, response, error) in
            var apiError: APIError?
            if let error = error {
                apiError = .genericRequestError(error)
            }
            completionHandler(data, response, apiError)
        }
    }
    
    func post(resource: APIResource, apiVersion: APIVersion, body: Data?, headers: [NetworkManager.PostHeader]?, completionHandler: @escaping (Data?, HTTPURLResponse?, APIError?) -> Void) {
        let endpoint = Endpoint(version: apiVersion, resource: resource, parameters: nil)
        guard let url = endpoint.url else {
            completionHandler(nil, nil, .invalidURL)
            return
        }
        let networkManager = NetworkManager.shared
        
        networkManager.makeRequest(type: .post, to: url, headers: headers, body: body) { (data , response, error) in
            var apiError: APIError?
            if let error = error {
                apiError = .genericRequestError(error)
            }
            completionHandler(data, response, apiError)
        }
    }
}
