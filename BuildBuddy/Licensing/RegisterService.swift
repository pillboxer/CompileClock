//
//  RegisterService.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 29/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import Cocoa
/// Carries out the commands to generate and persist the `License`
class RegisterService: HandlesRegistering {
    
    let factory: LicenseFactory
    let writer: LicenseWriter
    let broadcaster: LicenseChangeBroadcaster
    
    init(factory: LicenseFactory = LicenseFactory(),
         writer: LicenseWriter = LicenseWriter(),
         broadcaster: LicenseChangeBroadcaster = LicenseChangeBroadcaster()) {
        self.factory = factory
        self.writer = writer
        self.broadcaster = broadcaster
    }
    
    /// This takes a `name` and `licenseCode` as opposed to a license because it is misleading to directly create an object from user input. Usage of the `License` type is reserved for valid license information.
    func register(name: String, licenseCode: String) {
        guard let license = factory.license(name: name, licenseCode: licenseCode) else {
            NSAlert.showSimpleAlert(title: "Error", message: "License Code Invalid", isError: true, completionHandler: nil)
            return
        }
        writer.store(license)
        broadcaster.broadcast(.registered(license))
    }
    
}
