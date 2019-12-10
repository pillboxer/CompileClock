//
//  Environment.swift
//  CompileClock
//
//  Created by Henry Cooper on 05/10/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class Environment {
    
    enum EnivronmentType {
        case prod
        case dev
    }
    
    static var current: EnivronmentType {
        #if DEV
        return .dev
        #else
        return .prod
        #endif
    }
    
    static var isDev: Bool {
        return current == .dev
    }
    
}
