//
//  Router.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 29/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class Router<EndPoint: EndpointType>: NetworkRouter {
    
    private var task: URLSessionTask?
    
    func request<Response: APIResponse>(_ route: EndPoint, decoding response: Response.Type, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        do {
            let request = try buildRequest(from: route)
            task = session.dataTask(with: request) { data, urlResponse, error in
                if let error = error {
                    completion(nil, .routerError(error))
                    return
                }
                
                if let urlResponse = urlResponse as? HTTPURLResponse {
                    if urlResponse.statusCode == 404 {
                        completion(nil, .urlDoesNotExist)
                        return
                    }
                }
                
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(response.self, from: data)
                        if !response.success {
                            completion(nil, .responseError(response.statusCode, response.errorMessage))
                            return
                        }
                        completion(response, nil)
                    }
                    catch let error {
                        completion(nil, .decodingError(error.localizedDescription))
                    }
                }
            }
        }
        catch {
            completion(nil, .routerError(error))
        }
        task?.resume()
    }
    
    /// Converts an EndPointType to a BuildRequest
    private func buildRequest(from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path))
        request.httpMethod = route.method.rawValue
        do {
            switch route.task {
            case .request(let body, let urlParameters, let headers):
                try configure(body: body, urlParameters: urlParameters, request: &request)
                addAdditionalHeaders(headers, request: &request)
            }
            return request
        }
        catch {
            throw error
        }
    }
    
    private func addAdditionalHeaders(_ headers: [PostHeader]?, request: inout URLRequest) {
        guard let headers = headers else {
            return
        }
        for header in headers {
            request.addPostHeader(header)
        }
    }
    
    private func configure(body: RequestBody?, urlParameters: Parameters?, request: inout URLRequest) throws {
        do {
            if let body = body {
                try JSONBodyEncoder.encode(urlRequest: &request, with: body)
            }
            if let urlParameters = urlParameters {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        }
        catch let error {
            throw error
        }
    }
    
}
