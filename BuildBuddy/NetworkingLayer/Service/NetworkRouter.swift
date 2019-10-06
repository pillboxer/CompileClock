//
//  NetworkRouter.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 29/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

typealias NetworkRouterCompletion = (APIResponse?, APIError?) -> ()

protocol NetworkRouter: class {
    associatedtype EndPoint: EndpointType
    func request<Response: APIResponse>(_ route: EndPoint, decoding response: Response.Type, completion: @escaping NetworkRouterCompletion)
}
