//
//  LicensingProvider.swift
//  CompileClock
//
//  Created by Henry Cooper on 30/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

class LicensingProvider {
    
    let licenseProvider: LicenseProvider
    
    init(licenseProvider: LicenseProvider = LicenseProvider()) {
        self.licenseProvider = licenseProvider
    }
    
    private var license: License? {
        return licenseProvider.license
    }
    
    var licensing: Licensing {
        guard let license = license else {
            return .unregistered
        }
        return .registered(license)
    }

    var wasDownloadedFromAppStore: Bool {
        return Bundle.main.appStoreReceiptURL != nil
    }
    
}
