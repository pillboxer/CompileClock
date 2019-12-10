//
//  Licensing.swift
//  CompileClock
//
//  Created by Henry Cooper on 30/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

typealias UserInfo = [AnyHashable : Any]

/// Represents the state of the app being registered/unregistered
enum Licensing {
    case unregistered
    case registered(License)
}

extension Licensing {
    
    static let licenseChangedNotification: Notification.Name = Notification.Name(rawValue: "License Changed")
    
    var userInfo: UserInfo {
        switch self {
        case .unregistered:
            return ["registered": false]
        case .registered(let license):
            return ["registered": true,
                    "licensee": license.licensee,
                    "licenseCode": license.code]
        }
    }
    
    static func licensingFromUserInfo(_ userInfo: UserInfo) -> Licensing? {
        guard let isRegistered = userInfo["registered"] as? Bool else {
            return nil
        }
        
        if !isRegistered {
            return .unregistered
        }
        
        guard let licensee = userInfo["licensee"] as? String,
            let licenseCode = userInfo["licenseCode"] as? String else {
                return nil
        }
        
        return .registered(License(licensee: licensee, code: licenseCode))
        
    }
    
}
