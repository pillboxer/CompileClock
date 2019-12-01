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
    MIHxMIGpBgcqhkjOOAQBMIGdAkEApSsg5qx3OB9JG1VFjJgB7OdkDbflNGpnvrkk
    DzecqpUISAYWtlhaK8U3B2H90G2a47P7Dl7ZBc3NdHoy+2EL9wIVAJCIQ0QX1/m3
    4vzLYZA6LZFJ3WB1AkEAjTQuo5jxXmlob/KiQKDnItcltqgljohm4UgZOY9/HX7m
    ps7tDYUR99S3MDP31ImmOGJ8bsmuoLtsBIZruvMv6QNDAAJAOMUBNkXwsbMh9Ep5
    7m8oQkdHi4NmzxI3IzZGrabFMXo3qkP96Nj663JADEF1RodJcIIU2xYpqzx08Z4k
    UYR/jQ==
    -----END PUBLIC KEY-----
    """

    private static let appName = "compile-clock"
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
        let registrationStringWithNameAsTyped = "\(appName),\(name)"
        let registrationStringLowerCased = "\(appName),\(name.lowercased())"
        let registrationStringCapitalised = "\(appName),\(name.capitalized)"
        let registrationStringUpperCased = "\(appName),\(name.uppercased())"
        return verifier.verify(code, forName: registrationStringWithNameAsTyped) ||
                verifier.verify(code, forName: registrationStringLowerCased) ||
                verifier.verify(code, forName: registrationStringCapitalised) ||
                verifier.verify(code, forName: registrationStringUpperCased)
    }
}

