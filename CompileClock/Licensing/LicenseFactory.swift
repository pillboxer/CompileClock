//
//  LicenseFactory.swift
//  CompileClock
//
//  Created by Henry Cooper on 28/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

/// Generates valid licenses
class LicenseFactory {
    
    let licenseVerifier: LicenseKeyVerifier
    
    init(licenseVerifier: LicenseKeyVerifier) {
        self.licenseVerifier = licenseVerifier
    }
    
    /// Only provides a license if verification succeeds
    func license(name: String, licenseCode: String) -> License? {
        guard isValid(name: name, licenseCode: licenseCode) else {
            return nil
        }
        return License(licensee: name, code: licenseCode)
    }
    
    private func isValid(name: String, licenseCode: String) -> Bool {
        return licenseVerifier.licenseCodeIsValid(licenseCode, name: name)
    }
}

extension LicenseFactory {
    convenience init() {
        self.init(licenseVerifier: LicenseKeyVerifier())
    }
}
