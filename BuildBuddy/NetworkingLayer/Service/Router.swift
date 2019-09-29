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
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        do {
            let request = try buildRequest(from: route)
            task = session.dataTask(with: request) { data, response, error in
                completion(data, response, error)
            }
        }
        catch {
            completion(nil, nil, error)
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
            print(error)
            throw error
        }
    }
    
}
