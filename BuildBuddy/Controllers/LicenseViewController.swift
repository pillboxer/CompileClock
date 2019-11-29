//
//  LicenseViewController.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 29/11/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import Cocoa
import XCTest

protocol HandlesRegistering {
    func register(name: String, licenseCode: String)
}

class LicenseViewController: NSViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var licenseeTextField: NSTextField!
    @IBOutlet weak var licenseCodeTextField: NSTextField!
    @IBOutlet weak var registerButton: NSButton!
    
    // MARK: - Properties
    var eventHandler: HandlesRegistering?
    
    @IBAction func registerPressed(_ sender: Any) {
        let name = licenseeTextField.stringValue
        let code = licenseCodeTextField.stringValue
        eventHandler?.register(name: name, licenseCode: code)
    }
    
    func displayEmptyTextField() {
        licenseeTextField.stringValue = ""
        licenseCodeTextField.stringValue = ""
    }
    
    func displayLicenseInformation(_ license: License) {
        licenseeTextField.stringValue = license.licensee
        licenseCodeTextField.stringValue = license.code
    }
    
}



