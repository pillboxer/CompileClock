//
//  License.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 28/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

/// Representation Of A License

struct License {
    let licensee: String
    let code: String
}

extension License {
    
    struct DefaultsKey: RawRepresentable {
        let rawValue: String
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        static let licensee = DefaultsKey(rawValue: "licensee")
        static let licenseCode = DefaultsKey(rawValue: "license_code")
    }
}

extension UserDefaults {
    func licenseInformation(key: License.DefaultsKey) -> String? {
        return string(forKey: key.rawValue)
    }
}
