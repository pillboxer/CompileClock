//
//  LicenseProvider.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 28/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

/// Reads the license data from UserDefaults
class LicenseProvider {
    
    let defaults = UserDefaults.standard
    
    var licenseInformation: (name: String, licenseCode: String)? {
        guard let name = defaults.licenseInformation(key: .licensee), let code = defaults.licenseInformation(key: .licenseCode) else {
            return nil
        }
        return (name, code)
    }
}

extension LicenseProvider {
    
    /// The `factory` checks if it is valid, using its `verifier`
    func license(factory: LicenseFactory = LicenseFactory()) -> License? {
        guard let information = licenseInformation else {
            return nil
        }
        return factory.license(name: information.name, licenseCode: information.licenseCode)
    }
    
}
