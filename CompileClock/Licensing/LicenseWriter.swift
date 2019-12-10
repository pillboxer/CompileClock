//
//  LicenseWriter.swift
//  CompileClock
//
//  Created by Henry Cooper on 28/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

/// Writes licensing information to User Defaults
class LicenseWriter {

    let defaults = UserDefaults.standard
    
    func store(_ license: License) {
        store(licensee: license.licensee, code: license.code)
    }
    
    private func store(licensee: String, code: String) {
        defaults.setValue(licensee, forLicenseKey: .licensee)
        defaults.setValue(code, forLicenseKey: .licenseCode)
    }
    
}

extension UserDefaults {
    func setValue(_ value: String, forLicenseKey licenseKey: License.DefaultsKey) {
        setValue(value, forKey: licenseKey.rawValue)
    }
}
