//
//  URLParameterEncoder.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 28/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

struct URLParameterEncoder: ParameterEncoder {
    
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        guard let url = urlRequest.url else {
            throw EncodingError.encodingFailed
        }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let item = URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                urlComponents.queryItems?.append(item)
            }
            urlRequest.url = urlComponents.url
        }

        
    }
    
}
