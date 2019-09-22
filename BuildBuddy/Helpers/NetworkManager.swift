//
//  NetworkManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 22/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    enum RequestType: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum PostHeader {
        case jsonContentType
    }
    
    func makeRequest(type: RequestType, to url: URL, headers: [PostHeader]? = nil, body: Data? = nil, completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        if let headers = headers {
            for header in headers {
                request.addPostHeader(header)
            }
        }

        request.httpMethod = type.rawValue
        request.httpBody = body
        
        let session = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            completionHandler(data, httpResponse, error)
        }
        session.resume()
        
    }
    
}

extension URLRequest {
    
    mutating func addPostHeader(_ header: NetworkManager.PostHeader) {
        switch header {
        case .jsonContentType:
            addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
    
}
