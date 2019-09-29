//
//  URLRequest+Extensions.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 08/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

enum PostHeader {
    case jsonContentType
}

extension URLRequest {

    mutating func addPostHeader(_ header: PostHeader) {
        switch header {
        case .jsonContentType:
            addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}
