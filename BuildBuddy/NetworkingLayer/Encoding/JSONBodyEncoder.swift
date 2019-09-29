//
//  JSONParameterEncoder.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 28/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

/// Encodes body to JSON and adds to the URLRequest
struct JSONBodyEncoder: BodyEncoder {
    
    static func encode(urlRequest: inout URLRequest, with body: RequestBody) throws {
        if let encoded = body.encoded {
            urlRequest.httpBody = encoded
            urlRequest.addPostHeader(.jsonContentType)
        }
        else {
            throw EncodingError.encodingFailed
        }
    }
    
}

extension Encodable {
    var encoded: Data? {
        return try? JSONEncoder().encode(self)
    }
}
