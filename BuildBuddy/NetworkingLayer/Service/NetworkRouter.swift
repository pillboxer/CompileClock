//
//  NetworkRouter.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 29/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

typealias NetworkRouterCompletion = (Data?, URLResponse?, Error?) -> ()

protocol NetworkRouter: class {
    associatedtype EndPoint: EndpointType
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
}
