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
        print("I am dev")
        return .dev
        #else
        print("I am not dev")
        return .prod
        #endif
    }
    
    static var isDev: Bool {
        return current == .dev
    }
    
}
