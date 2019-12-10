//
//  LicenseViewController.swift
//  CompileClock
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
    @IBOutlet weak var buyButton: NSButton!
    @IBOutlet weak var licenseInformationLabel: NSTextField!
    
    // MARK: - Properties
    var eventHandler: HandlesRegistering?
    
    @IBAction func registerPressed(_ sender: Any) {
        let name = licenseeTextField.stringValue
        let code = licenseCodeTextField.stringValue
        eventHandler?.register(name: name, licenseCode: code)
    }
    
    @IBAction func buyNowPressed(_ sender: Any) {
        let url = URL(string: "https://compileclock.test.onfastspring.com/compile-clock")!
        NSWorkspace.shared.open(url)
    }
    
    
    // MARK: - Public Methods
    
    func displayEmptyTextField() {
        licenseeTextField.stringValue = ""
        licenseCodeTextField.stringValue = ""
    }
    
    func displayLicenseInformation(_ license: License) {
        licenseeTextField.stringValue = license.licensee
        licenseCodeTextField.stringValue = license.code
        licenseeTextField.isEditable = false
        licenseCodeTextField.isEditable = false
        buyButton.isEnabled = false
        registerButton.isEnabled = false
        licenseInformationLabel.stringValue = "Thanks for your support. Your purchase information is below"
    }
    
}

extension LicenseViewController: NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        validateTextFields()
    }
    
    func validateTextFields() {
        registerButton.isEnabled = !(licenseeTextField.stringValue.isEmpty || licenseCodeTextField.stringValue.isEmpty)
    }
    
}



