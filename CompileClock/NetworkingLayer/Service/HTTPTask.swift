//
//  HTTPTask.swift
//  CompileClock
//
//  Created by Henry Cooper on 28/09/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

/// This enum is responsible for configuring parameters for a specific endpoint.
enum HTTPTask {
    case request(body: RequestBody?, urlParameters: Parameters?, headers: [PostHeader]?)
}
