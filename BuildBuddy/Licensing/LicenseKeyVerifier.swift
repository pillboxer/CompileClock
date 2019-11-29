//
//  LicenseKeyVerifier.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 28/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Foundation
import CocoaFob

/// Verifies a license key 
class LicenseKeyVerifier {
    private static let publicKey = """
    -----BEGIN PUBLIC KEY-----
    MIHwMIGoBgcqhkjOOAQBMIGcAkEAr53x6K8/dFwp9oGHLbI1x5bw0aeOHQR4wQ5D
    SYGjsZdTC5F/r9F1PdrlcrWbdYqAt0Fa8l6UFml2uvHoHK++YwIVALCDk1ftAXMQ
    iaIGhYtbDfdE7qTTAkBwzBF9KoHEs/WVT9Qhvs+v+UwGerafksMZ8y5cUCmDjHIT
    uqzNlRokyFDbZu8WevKj94uq79JDXbPDMwc8Ax/5A0MAAkAc74exY96mfAGSTyLU
    mDJyKZjfP1acK8irpX9yDaltNEiDwV3CbHGd+e8EBH0vIzrXUG4f5CSilv6NWMc0
    IqcP
    -----END PUBLIC KEY-----
    """

    private static let appName = "CompileClock"
    let appName: String
    
    convenience init() {
        self.init(appName: LicenseKeyVerifier.appName)
    }
    
    private init(appName: String) {
        self.appName = appName
    }
    
    func licenseCodeIsValid(_ code: String, name: String) -> Bool {
        guard let verifier = LicenseVerifier(publicKeyPEM: LicenseKeyVerifier.publicKey) else {
            LogUtility.updateLogWithEvent(.couldNotCreateLicenseVerifier)
            return false
        }
        return verifier.verify(code, forName: name)
    }
}

