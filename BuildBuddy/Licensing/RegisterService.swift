//
//  RegisterService.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 29/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation

/// Carries out the commands to generate and persist the `License`
class RegisterService {
    
    let factory: LicenseFactory
    let writer: LicenseWriter
    
    init(factory: LicenseFactory, writer: LicenseWriter) {
        self.factory = factory
        self.writer = writer
    }
    
    /// This takes a `name` and `licenseCode` as opposed to a license because it is misleading to directly create an object from user input. Usage of the `License` type is reserved for valid license information.
    func register(name: String, licenseCode: String) {
        guard let license = factory.license(name: name, licenseCode: licenseCode) else {
            return
        }
        writer.store(license)
    }
    
}
