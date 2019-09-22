//
//  NetworkManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 22/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class NetworkManager {
    
    enum RequestType: String {
        case get = "GET"
        case post = "POST"
    }
    
    static func makeRequest(type: RequestType, to url: URL, headers: [String : String]? = nil, body: Data? = nil, completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(key, forHTTPHeaderField: value)
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
