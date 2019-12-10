//
//  ParametersEncoding.swift
//  CompileClock
//
//  Created by Henry Cooper on 28/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

typealias Parameters = [String:Any]
typealias RequestBody = Encodable

enum EncodingError: String, Error {
    case encodingFailed = "Encoding failed"
    case urlMissing = "The url does not exist"
}

protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

protocol BodyEncoder {
    static func encode(urlRequest: inout URLRequest, with body: RequestBody) throws
}
