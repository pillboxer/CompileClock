//
//  URLRequest+Extensions.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 08/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

extension URLRequest {
    
    static func postRequestToURL(_ url: URL, data: Data?, completion: @escaping ( HTTPURLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            completion(response as? HTTPURLResponse, error)
        }
        task.resume()
    }
    
}
